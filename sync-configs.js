#!/usr/bin/env node

/**
 * Sync Configuration Generator
 * 
 * Legge base-config.json e genera automaticamente:
 * - claude-vscode.json (Claude Code per VS Code)
 * - claude-cli-config.json (Claude CLI per terminale)
 * - github-copilot-vscode.json (GitHub Copilot per VS Code)
 * 
 * Nota: WARP.md è un file manuale (non auto-generato)
 * 
 * Usage: node sync-configs.js
 */

const fs = require('fs');
const path = require('path');

const CONFIG_DIR = path.join(__dirname, 'ai-configurations');
const BASE_CONFIG_PATH = path.join(CONFIG_DIR, 'base-config.json');

// Leggi base-config.json
const baseConfig = JSON.parse(fs.readFileSync(BASE_CONFIG_PATH, 'utf8'));

console.log('🔄 Sincronizzazione configurazioni da base-config.json...\n');

// ============================================
// HELPER FUNCTIONS
// ============================================

/**
 * Estrae librerie da tech_stack con supporto per strutture annidate
 */
function extractLibraries(stackSection) {
  const libraries = [];
  
  function traverse(obj, prefix = '') {
    if (Array.isArray(obj)) {
      obj.forEach(item => {
        if (typeof item === 'string') {
          libraries.push(item);
        } else if (typeof item === 'object' && item.name) {
          // Libreria con meta-campi (priority, rationale, etc.)
          const priority = item.priority ? `[${item.priority}]` : '';
          libraries.push(`${item.name} ${priority}`.trim());
        }
      });
    } else if (typeof obj === 'object' && obj !== null) {
      Object.entries(obj).forEach(([key, value]) => {
        if (key !== 'constraints' && key !== 'core') {
          traverse(value, prefix ? `${prefix}.${key}` : key);
        } else if (key === 'core') {
          traverse(value, prefix);
        }
      });
    }
  }
  
  traverse(stackSection);
  return libraries;
}

/**
 * Formatta il tech stack per il markdown
 */
function formatTechStackSection(section, title) {
  const libraries = extractLibraries(section);
  if (libraries.length === 0) return '';
  
  return `### ${title}\n${libraries.map(l => `- ${l}`).join('\n')}\n`;
}

// ============================================
// 1. GENERA claude-vscode.json
// ============================================
function generateClaudeConfig() {
  const config = {
    "$schema": "https://json-schema.org/draft-07/schema",
    "_comment": "Auto-generato da base-config.json - NON MODIFICARE MANUALMENTE",
    "_generated_at": new Date().toISOString(),
    
    "claude.apiKey": "YOUR_API_KEY_HERE",
    "claude.modelId": "claude-sonnet-4-5-20250929",
    "claude.maxTokens": 8192,
    "claude.temperature": baseConfig.ai_parameters.temperature,
    
    "claude.contextWindow": {
      "includeOpenFiles": true,
      "includeRecentFiles": true,
      "maxFiles": 20,
      "includeGitChanges": true,
      "includeWorkspaceSymbols": true
    },
    
    "claude.customInstructions": baseConfig.custom_instructions_template,
    
    "claude.filePatterns": {
      "exclude": baseConfig.file_patterns.exclude
    },
    
    "claude.features": {
      "autoComplete": true,
      "inlineChat": true,
      "codeActions": true,
      "gitIntegration": true,
      "testGeneration": true,
      "refactoring": true,
      "documentation": true
    }
  };

  const filePath = path.join(CONFIG_DIR, 'claude-vscode.json');
  fs.writeFileSync(filePath, JSON.stringify(config, null, 2), 'utf8');
  console.log('✅ claude-vscode.json generato');
}

// ============================================
// 2. GENERA claude-cli-config.json
// ============================================
function generateClaudeCLIConfig() {
  // Versione compatta delle istruzioni per CLI
  const compactInstructions = [
    "=== MODEL IDENTITY ===",
    "You are Claude Sonnet 4.5 (claude-sonnet-4-5-20250929), created by Anthropic.",
    "Current model: Claude Sonnet 4.5",
    "",
    "=== DEVELOPER PROFILE ===",
    "Full-stack developer specializzato in:",
    "• Frontend: React, React Native, Next.js, TypeScript, iOS (Swift)",
    "• Backend: Node.js (Express, Fastify, NestJS), Python (FastAPI, Flask)",
    "• Database: Supabase, PostgreSQL, MongoDB, Redis",
    "• Infrastructure: Docker, Vercel, Render, GitHub Actions, GitLab CI",
    "• Automation: n8n workflows",
    "• Mobile: React Native, Expo, iOS Native",
    "",
    "=== CODING RULES (ABSOLUTE) ===",
    "1. ⚠️ MAX 25 RIGHE per funzione/metodo (NON NEGOZIABILE)",
    "2. 🎯 Design Patterns OBBLIGATORI: DI, Strategy, CQRS, Business Delegate, Repository",
    "3. 🚫 ZERO TOLLERANZA: God Objects, codice duplicato, magic numbers, nested conditionals >3",
    "4. ✅ Testing OBBLIGATORIO: Unit test per business logic, coverage ≥80%",
    "5. 🔍 Linting SEMPRE ATTIVO: ESLint+Prettier (JS/TS), Pylint+Black (Python)",
    "",
    "=== GOLDEN RULES ===",
    baseConfig.golden_rules ? baseConfig.golden_rules.slice(0, 7).map(r => `• ${r.rule}`).join('\n') : 
    "• KISS: Keep It Simple\n• YAGNI: You Aren't Gonna Need It\n• Measure Before Optimize\n• Fail Fast, Recover Gracefully\n• Single Source of Truth\n• Security by Design\n• Observability by Default",
    "",
    "=== OUTPUT ===",
    `• Codice: ${baseConfig.ai_parameters.code_language.toUpperCase()} | Spiegazioni: ${baseConfig.ai_parameters.explanation_language.toUpperCase()}`,
    "• Production-ready + unit tests + docs",
    "• Lint-free, type-safe, secure",
    "• Soluzione generale, NON hard-coded"
  ];

  const config = {
    "_comment": "Auto-generato da base-config.json - NON MODIFICARE MANUALMENTE",
    "_generated_at": new Date().toISOString(),
    "_usage": "Copia questo file in ~/.config/claude/config.json oppure usa come .claude nel progetto",
    
    "model": "claude-sonnet-4-5-20250929",
    "temperature": baseConfig.ai_parameters.temperature,
    "max_tokens": 8192,
    
    "custom_instructions": compactInstructions,
    
    "context": {
      "include_git_diff": true,
      "include_open_files": true,
      "max_context_tokens": 100000,
      "watch_files": [
        "**/*.ts",
        "**/*.tsx",
        "**/*.js",
        "**/*.jsx",
        "**/*.py",
        "**/*.swift",
        "**/*.json",
        "**/*.md"
      ]
    },
    
    "exclude_patterns": baseConfig.file_patterns.exclude,
    
    "features": {
      "auto_commit": false,
      "interactive_mode": true,
      "verbose": false,
      "color_output": true
    }
  };

  const filePath = path.join(CONFIG_DIR, 'claude-cli-config.json');
  fs.writeFileSync(filePath, JSON.stringify(config, null, 2), 'utf8');
  console.log('✅ claude-cli-config.json generato');
}

// ============================================
// 3. GENERA github-copilot-vscode.json
// ============================================
function generateGitHubCopilotConfig() {
  // Estrae librerie principali per istruzioni compatte
  const frontendLibs = extractLibraries(baseConfig.tech_stack.frontend).slice(0, 3);
  const backendCore = baseConfig.tech_stack.backend.core || baseConfig.tech_stack.backend;
  const backendLibs = Array.isArray(backendCore) ? backendCore.slice(0, 2) : extractLibraries(baseConfig.tech_stack.backend).slice(0, 2);
  const databaseLibs = baseConfig.tech_stack.database.slice(0, 2);
  
  // Crea versione compatta delle istruzioni
  const compactInstructions = [
    {
      "text": `Tech Stack: ${frontendLibs.join(', ')}, ${backendLibs.join(', ')}, ${databaseLibs.join(', ')}`
    },
    {
      "text": `AI Params: Temperature ${baseConfig.ai_parameters.temperature} | Mode: ${baseConfig.ai_parameters.optimization_mode} | Verbosity: ${baseConfig.ai_parameters.verbosity}`
    },
    {
      "text": `RULES: 1) MAX ${baseConfig.coding_standards.general.max_function_length} lines/function 2) Patterns: ${baseConfig.coding_standards.patterns.required.slice(0, 3).join(', ')} 3) Tests ≥${baseConfig.quality_requirements.testing.coverage_threshold}% 4) Linting always`
    },
    {
      "text": `Style: TypeScript strict | Async/await | Functional | Type hints | Composition over inheritance`
    },
    {
      "text": `Output: Production-ready | Unit tests | Docs (${baseConfig.ai_parameters.explanation_language}) | Security | Performance | Lint-free`
    },
    {
      "text": `Language: Explanations ${baseConfig.ai_parameters.explanation_language.toUpperCase()} | Code ${baseConfig.ai_parameters.code_language.toUpperCase()}`
    },
    {
      "text": `Golden Rules: ${baseConfig.golden_rules ? baseConfig.golden_rules.slice(0, 3).map(r => r.rule).join(' | ') : 'KISS, YAGNI, Measure Before Optimize'}`
    }
  ];

  const config = {
    "_comment": "Auto-generato da base-config.json - NON MODIFICARE MANUALMENTE",
    "_generated_at": new Date().toISOString(),
    
    "github.copilot.enable": {
      "*": true,
      "yaml": true,
      "markdown": true,
      "typescript": true,
      "python": true,
      "swift": true
    },
    
    "github.copilot.editor.enableAutoCompletions": true,
    "github.copilot.editor.enableCodeActions": true,
    
    "editor.inlineSuggest.enabled": true,
    "editor.inlineSuggest.showToolbar": "onHover",
    
    "editor.quickSuggestions": {
      "other": true,
      "comments": true,
      "strings": true
    },
    
    "editor.suggestOnTriggerCharacters": true,
    "editor.acceptSuggestionOnCommitCharacter": true,
    "editor.acceptSuggestionOnEnter": "on",
    "editor.tabCompletion": "on",
    
    "github.copilot.chat.localeOverride": baseConfig.ai_parameters.explanation_language,
    "github.copilot.chat.codeGeneration.instructions": compactInstructions,
    "github.copilot.chat.welcomeMessage": "enabled",
    
    "files.exclude": {
      "**/.git": true,
      "**/.DS_Store": true,
      "**/node_modules": true,
      "**/__pycache__": true,
      "**/venv": true,
      "**/*.pyc": true
    },
    
    "github.copilot.advanced": {
      "temperature": baseConfig.ai_parameters.temperature,
      "length": "medium"
    },
    
    "editor.fontSize": 14,
    "editor.fontFamily": "'Fira Code', 'JetBrains Mono', Menlo, monospace",
    "editor.fontLigatures": true,
    "editor.lineHeight": 22,
    "editor.formatOnSave": baseConfig.quality_requirements.linting.enforce_on_save,
    "editor.formatOnPaste": true,
    "editor.codeActionsOnSave": {
      "source.fixAll.eslint": "explicit",
      "source.organizeImports": "explicit"
    },
    "editor.bracketPairColorization.enabled": true,
    "editor.rulers": [80, 120],
    
    "typescript.updateImportsOnFileMove.enabled": "always",
    "python.linting.enabled": baseConfig.quality_requirements.linting.required,
    "python.linting.pylintEnabled": true,
    "python.formatting.provider": "black",
    
    "eslint.validate": ["javascript", "javascriptreact", "typescript", "typescriptreact"],
    
    "workbench.colorTheme": "GitHub Dark Default",
    "workbench.iconTheme": "material-icon-theme",
    "terminal.integrated.fontSize": 13,
    "terminal.integrated.defaultProfile.osx": "zsh"
  };

  const filePath = path.join(CONFIG_DIR, 'github-copilot-vscode.json');
  fs.writeFileSync(filePath, JSON.stringify(config, null, 2), 'utf8');
  console.log('✅ github-copilot-vscode.json generato');
}

// ============================================
// MAIN
// ============================================
try {
  generateClaudeConfig();
  generateClaudeCLIConfig();
  generateGitHubCopilotConfig();
  
  console.log('\n✨ Sincronizzazione completata!');
  console.log('\n📝 File generati:');
  console.log('  - ai-configurations/claude-vscode.json (VS Code extension)');
  console.log('  - ai-configurations/claude-cli-config.json (CLI terminal)');
  console.log('  - ai-configurations/github-copilot-vscode.json');
  console.log('\n📖 Documentazione: ai-configurations/README.md');
  console.log('💡 Modifica solo base-config.json e riesegui questo script.\n');
  
} catch (error) {
  console.error('❌ Errore durante la sincronizzazione:', error.message);
  process.exit(1);
}
