#!/usr/bin/env node

/**
 * Test Suite per Configurazioni AI
 * 
 * Valida:
 * - JSON syntax
 * - Struttura base-config.json
 * - File generati esistenti e validi
 * - Coerenza tra base-config e file generati
 * - Requisiti minimi (temperature, version, ecc.)
 */

const fs = require('fs');
const path = require('path');

const CONFIG_DIR = path.join(__dirname, 'ai-configurations');
const BASE_CONFIG_PATH = path.join(CONFIG_DIR, 'base-config.json');

// Colori per output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m'
};

let passedTests = 0;
let failedTests = 0;
const errors = [];

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function pass(testName) {
  passedTests++;
  log(`✅ ${testName}`, 'green');
}

function fail(testName, error) {
  failedTests++;
  errors.push({ test: testName, error });
  log(`❌ ${testName}`, 'red');
  log(`   ${error}`, 'red');
}

function section(title) {
  console.log();
  log(`${'='.repeat(60)}`, 'cyan');
  log(`  ${title}`, 'cyan');
  log(`${'='.repeat(60)}`, 'cyan');
}

// ============================================
// TEST 1: File Existence
// ============================================
function testFileExistence() {
  section('TEST 1: File Existence');
  
  const requiredFiles = [
    'base-config.json',
    'claude-vscode.json',
    'claude-cli-config.json',
    'github-copilot-vscode.json',
    'warp-config.md',
    'README.md'
  ];
  
  requiredFiles.forEach(file => {
    const filePath = path.join(CONFIG_DIR, file);
    if (fs.existsSync(filePath)) {
      pass(`File exists: ${file}`);
    } else {
      fail(`File exists: ${file}`, `File not found: ${filePath}`);
    }
  });
}

// ============================================
// TEST 2: JSON Validity
// ============================================
function testJsonValidity() {
  section('TEST 2: JSON Validity');
  
  const jsonFiles = [
    'base-config.json',
    'claude-vscode.json',
    'claude-cli-config.json',
    'github-copilot-vscode.json'
  ];
  
  jsonFiles.forEach(file => {
    const filePath = path.join(CONFIG_DIR, file);
    try {
      const content = fs.readFileSync(filePath, 'utf8');
      JSON.parse(content);
      pass(`Valid JSON: ${file}`);
    } catch (error) {
      fail(`Valid JSON: ${file}`, error.message);
    }
  });
}

// ============================================
// TEST 3: Base Config Structure
// ============================================
function testBaseConfigStructure() {
  section('TEST 3: Base Config Structure');
  
  try {
    const baseConfig = JSON.parse(fs.readFileSync(BASE_CONFIG_PATH, 'utf8'));
    
    // Required top-level keys
    const requiredKeys = [
      'version',
      'ai_parameters',
      'tech_stack',
      'coding_standards',
      'quality_requirements',
      'best_practices',
      'golden_rules',
      'warnings',
      'compatibility',
      'file_patterns',
      'custom_instructions_template'
    ];
    
    requiredKeys.forEach(key => {
      if (baseConfig.hasOwnProperty(key)) {
        pass(`Has required key: ${key}`);
      } else {
        fail(`Has required key: ${key}`, `Missing key in base-config.json`);
      }
    });
    
    // Test ai_parameters
    if (baseConfig.ai_parameters) {
      const { temperature } = baseConfig.ai_parameters;
      if (temperature >= 0 && temperature <= 1) {
        pass(`Temperature in valid range: ${temperature}`);
      } else {
        fail(`Temperature in valid range`, `Temperature ${temperature} not in [0, 1]`);
      }
    }
    
    // Test tech_stack structure
    if (baseConfig.tech_stack) {
      const sections = ['frontend', 'backend', 'mobile', 'python_advanced', 'database'];
      sections.forEach(section => {
        if (baseConfig.tech_stack[section]) {
          pass(`Tech stack has section: ${section}`);
        } else {
          fail(`Tech stack has section: ${section}`, `Missing ${section} in tech_stack`);
        }
      });
    }
    
    // Test golden_rules
    if (Array.isArray(baseConfig.golden_rules)) {
      if (baseConfig.golden_rules.length > 0) {
        pass(`Golden rules defined (${baseConfig.golden_rules.length} rules)`);
        
        // Check first rule has required fields
        const firstRule = baseConfig.golden_rules[0];
        const ruleFields = ['rule', 'rationale', 'priority'];
        ruleFields.forEach(field => {
          if (firstRule[field]) {
            pass(`Golden rule has field: ${field}`);
          } else {
            fail(`Golden rule has field: ${field}`, `Missing ${field} in golden_rules`);
          }
        });
      } else {
        fail(`Golden rules defined`, `golden_rules array is empty`);
      }
    }
    
    // Test warnings
    if (Array.isArray(baseConfig.warnings)) {
      if (baseConfig.warnings.length > 0) {
        pass(`Warnings defined (${baseConfig.warnings.length} warnings)`);
        
        const firstWarning = baseConfig.warnings[0];
        const warningFields = ['category', 'warning', 'rationale', 'mitigation'];
        warningFields.forEach(field => {
          if (firstWarning[field]) {
            pass(`Warning has field: ${field}`);
          } else {
            fail(`Warning has field: ${field}`, `Missing ${field} in warnings`);
          }
        });
      }
    }
    
    // Test compatibility
    if (baseConfig.compatibility) {
      const platforms = ['node', 'python', 'react', 'typescript'];
      platforms.forEach(platform => {
        if (baseConfig.compatibility[platform]) {
          pass(`Compatibility defined for: ${platform}`);
        }
      });
    }
    
  } catch (error) {
    fail('Base config structure', error.message);
  }
}

// ============================================
// TEST 4: Generated Files Consistency
// ============================================
function testGeneratedFilesConsistency() {
  section('TEST 4: Generated Files Consistency');
  
  try {
    const baseConfig = JSON.parse(fs.readFileSync(BASE_CONFIG_PATH, 'utf8'));
    
    // Test claude-vscode.json
    const claudeVscode = JSON.parse(
      fs.readFileSync(path.join(CONFIG_DIR, 'claude-vscode.json'), 'utf8')
    );
    
    if (claudeVscode['claude.temperature'] === baseConfig.ai_parameters.temperature) {
      pass('Claude VS Code temperature matches base config');
    } else {
      fail('Claude VS Code temperature matches', 
        `Expected ${baseConfig.ai_parameters.temperature}, got ${claudeVscode['claude.temperature']}`);
    }
    
    if (claudeVscode['claude.modelId'] === 'claude-sonnet-4-5-20250929') {
      pass('Claude VS Code model ID is correct');
    } else {
      fail('Claude VS Code model ID', `Got ${claudeVscode['claude.modelId']}`);
    }
    
    // Test claude-cli-config.json
    const claudeCli = JSON.parse(
      fs.readFileSync(path.join(CONFIG_DIR, 'claude-cli-config.json'), 'utf8')
    );
    
    if (claudeCli.temperature === baseConfig.ai_parameters.temperature) {
      pass('Claude CLI temperature matches base config');
    } else {
      fail('Claude CLI temperature matches',
        `Expected ${baseConfig.ai_parameters.temperature}, got ${claudeCli.temperature}`);
    }
    
    if (claudeCli.model === 'claude-sonnet-4-5-20250929') {
      pass('Claude CLI model ID is correct');
    } else {
      fail('Claude CLI model ID', `Got ${claudeCli.model}`);
    }
    
    // Test github-copilot-vscode.json
    const githubCopilot = JSON.parse(
      fs.readFileSync(path.join(CONFIG_DIR, 'github-copilot-vscode.json'), 'utf8')
    );
    
    if (githubCopilot['github.copilot.advanced']?.temperature === baseConfig.ai_parameters.temperature) {
      pass('GitHub Copilot temperature matches base config');
    } else {
      fail('GitHub Copilot temperature matches',
        `Expected ${baseConfig.ai_parameters.temperature}`);
    }
    
    // Check auto-generated comments
    const hasComment = claudeVscode._comment && 
                      claudeVscode._comment.includes('Auto-generato da base-config.json');
    if (hasComment) {
      pass('Generated files have auto-generated comment');
    } else {
      fail('Generated files have comment', 'Missing or incorrect _comment field');
    }
    
  } catch (error) {
    fail('Generated files consistency', error.message);
  }
}

// ============================================
// TEST 5: Best Practices Validation
// ============================================
function testBestPractices() {
  section('TEST 5: Best Practices Validation');
  
  try {
    const baseConfig = JSON.parse(fs.readFileSync(BASE_CONFIG_PATH, 'utf8'));
    
    // Check max function length is reasonable
    const maxLength = baseConfig.coding_standards?.general?.max_function_length;
    if (maxLength && maxLength >= 15 && maxLength <= 50) {
      pass(`Max function length is reasonable: ${maxLength} lines`);
    } else {
      fail('Max function length', `Value ${maxLength} should be between 15 and 50`);
    }
    
    // Check test coverage threshold
    const coverage = baseConfig.quality_requirements?.testing?.coverage_threshold;
    if (coverage && coverage >= 70 && coverage <= 100) {
      pass(`Test coverage threshold is reasonable: ${coverage}%`);
    } else {
      fail('Test coverage threshold', `Value ${coverage} should be between 70 and 100`);
    }
    
    // Check design patterns are defined
    const patterns = baseConfig.coding_standards?.patterns?.required;
    if (Array.isArray(patterns) && patterns.length >= 3) {
      pass(`Design patterns defined: ${patterns.length} patterns`);
    } else {
      fail('Design patterns', 'Should have at least 3 required patterns');
    }
    
    // Check tech stack has meta-fields
    const frontend = baseConfig.tech_stack?.frontend;
    if (frontend && frontend.ui_libraries) {
      const firstLib = frontend.ui_libraries.design_systems?.[0];
      if (firstLib && firstLib.priority && firstLib.rationale) {
        pass('Tech stack libraries have meta-fields (priority, rationale)');
      } else {
        fail('Tech stack meta-fields', 'Libraries should have priority and rationale');
      }
    }
    
  } catch (error) {
    fail('Best practices validation', error.message);
  }
}

// ============================================
// TEST 6: File Patterns
// ============================================
function testFilePatterns() {
  section('TEST 6: File Patterns');
  
  try {
    const baseConfig = JSON.parse(fs.readFileSync(BASE_CONFIG_PATH, 'utf8'));
    
    const exclude = baseConfig.file_patterns?.exclude;
    if (Array.isArray(exclude) && exclude.length > 0) {
      pass(`File exclusion patterns defined: ${exclude.length} patterns`);
      
      // Check common patterns
      const commonPatterns = [
        '**/node_modules/**',
        '**/.git/**',
        '**/dist/**',
        '**/__pycache__/**'
      ];
      
      commonPatterns.forEach(pattern => {
        if (exclude.includes(pattern)) {
          pass(`Excludes common pattern: ${pattern}`);
        } else {
          fail(`Excludes common pattern: ${pattern}`, 'Pattern not found in exclusions');
        }
      });
    } else {
      fail('File patterns defined', 'No exclusion patterns found');
    }
    
  } catch (error) {
    fail('File patterns test', error.message);
  }
}

// ============================================
// TEST 7: Custom Instructions
// ============================================
function testCustomInstructions() {
  section('TEST 7: Custom Instructions');
  
  try {
    const baseConfig = JSON.parse(fs.readFileSync(BASE_CONFIG_PATH, 'utf8'));
    
    const instructions = baseConfig.custom_instructions_template;
    if (Array.isArray(instructions) && instructions.length > 0) {
      pass(`Custom instructions defined: ${instructions.length} lines`);
      
      // Check for key sections
      const instructionsText = instructions.join('\n');
      const sections = [
        'MODEL IDENTITY',
        'DEVELOPER PROFILE',
        'CODING RULES',
        'GOLDEN RULES',
        'OUTPUT'
      ];
      
      sections.forEach(section => {
        if (instructionsText.includes(section)) {
          pass(`Instructions contain section: ${section}`);
        } else {
          fail(`Instructions contain section: ${section}`, 'Section not found');
        }
      });
      
      // Check Claude 4.5 specific tags
      const claudeTags = [
        '<default_to_action>',
        '<investigate_before_answering>',
        '<use_parallel_tool_calls>'
      ];
      
      claudeTags.forEach(tag => {
        if (instructionsText.includes(tag)) {
          pass(`Instructions contain Claude 4.5 tag: ${tag}`);
        } else {
          fail(`Instructions contain Claude 4.5 tag: ${tag}`, 'Tag not found');
        }
      });
      
    } else {
      fail('Custom instructions defined', 'No custom instructions found');
    }
    
  } catch (error) {
    fail('Custom instructions test', error.message);
  }
}

// ============================================
// MAIN
// ============================================
function main() {
  console.clear();
  log('╔════════════════════════════════════════════════════════════╗', 'cyan');
  log('║           AI Configurations Test Suite                    ║', 'cyan');
  log('╚════════════════════════════════════════════════════════════╝', 'cyan');
  
  testFileExistence();
  testJsonValidity();
  testBaseConfigStructure();
  testGeneratedFilesConsistency();
  testBestPractices();
  testFilePatterns();
  testCustomInstructions();
  
  // Summary
  console.log();
  log('='.repeat(60), 'cyan');
  log('  TEST SUMMARY', 'cyan');
  log('='.repeat(60), 'cyan');
  console.log();
  
  log(`✅ Passed: ${passedTests}`, 'green');
  log(`❌ Failed: ${failedTests}`, failedTests > 0 ? 'red' : 'green');
  log(`📊 Total:  ${passedTests + failedTests}`, 'blue');
  
  if (failedTests > 0) {
    console.log();
    log('Failed Tests Details:', 'yellow');
    errors.forEach((err, i) => {
      log(`${i + 1}. ${err.test}`, 'yellow');
      log(`   ${err.error}`, 'red');
    });
  }
  
  console.log();
  
  if (failedTests === 0) {
    log('🎉 All tests passed! Configurations are valid.', 'green');
    process.exit(0);
  } else {
    log('⚠️  Some tests failed. Please review the errors above.', 'red');
    process.exit(1);
  }
}

main();
