#!/usr/bin/env node

/**
 * Sync Configuration Generator
 * 
 * Legge base-config.json e genera automaticamente:
 * - claude-vscode.json
 * - github-copilot-vscode.json
 * - INSTRUCTIONS.md
 * 
 * Usage: node sync-configs.js
 */

const fs = require('fs');
const path = require('path');

const CONFIG_DIR = path.join(__dirname, 'configurations');
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
// 1. GENERA INSTRUCTIONS.md
// ============================================
function generateInstructions() {
  const instructions = baseConfig.custom_instructions_template.join('\n');
  
  // Formatta tech stack
  let techStackSections = '';
  
  if (baseConfig.tech_stack.frontend) {
    techStackSections += formatTechStackSection(baseConfig.tech_stack.frontend, 'Frontend');
  }
  if (baseConfig.tech_stack.backend) {
    techStackSections += formatTechStackSection(baseConfig.tech_stack.backend, 'Backend');
  }
  if (baseConfig.tech_stack.mobile) {
    techStackSections += formatTechStackSection(baseConfig.tech_stack.mobile, 'Mobile');
  }
  if (baseConfig.tech_stack.python_advanced) {
    techStackSections += formatTechStackSection(baseConfig.tech_stack.python_advanced, 'Python Advanced');
  }
  if (baseConfig.tech_stack.database) {
    techStackSections += formatTechStackSection(baseConfig.tech_stack.database, 'Database');
  }
  if (baseConfig.tech_stack.infrastructure) {
    techStackSections += formatTechStackSection(baseConfig.tech_stack.infrastructure, 'Infrastructure');
  }
  
  const content = `# 📋 Istruzioni Custom per AI Copilots

> Da copiare manualmente nelle impostazioni di ciascun copilot
> **Auto-generato da base-config.json**

---

## 🎯 Istruzioni Complete

\`\`\`markdown
${instructions}
\`\`\`

---

## 🔧 Come Applicare

### Claude Code (VS Code)
1. Apri Settings (Cmd+,)
2. Cerca "Claude Custom Instructions"
3. Incolla le istruzioni sopra
4. Imposta temperature: ${baseConfig.ai_parameters.temperature}

### GitHub Copilot (VS Code)
1. Apri Command Palette (Cmd+Shift+P)
2. Cerca "GitHub Copilot: Edit Instructions"
3. Incolla la versione compatta delle istruzioni
4. Salva

### Warp AI
1. Apri Warp
2. Usa \`Ctrl+Shift+R\` per AI
3. Nelle impostazioni AI, aggiungi context personalizzato

---

## 📊 Parametri AI

- **Temperature**: ${baseConfig.ai_parameters.temperature}
- **Creativity**: ${baseConfig.ai_parameters.creativity_level}
- **Verbosity**: ${baseConfig.ai_parameters.verbosity}
- **Mode**: ${baseConfig.ai_parameters.optimization_mode}

---

## 🛠️ Tech Stack

${techStackSections}

---

## 📏 Coding Standards

### General
- Max function length: ${baseConfig.coding_standards.general.max_function_length} lines
- Max method length: ${baseConfig.coding_standards.general.max_method_length} lines
- Prefer code reuse: ${baseConfig.coding_standards.general.prefer_code_reuse}
- Single responsibility: ${baseConfig.coding_standards.general.single_responsibility}

### Required Patterns
${baseConfig.coding_standards.patterns.required.map(p => `- ${p}`).join('\n')}

### Antipatterns to Avoid
${baseConfig.coding_standards.antipatterns_to_avoid.map(a => `- ${a}`).join('\n')}

---

## 🎯 Golden Rules

${baseConfig.golden_rules ? baseConfig.golden_rules.map(r => `### ${r.rule}\n**Priority**: ${r.priority} | **Rationale**: ${r.rationale}\n`).join('\n') : ''}

---

## ⚠️ Warnings & Best Practices

${baseConfig.warnings ? baseConfig.warnings.map(w => `**[${w.category}]** ${w.warning}\n- Rationale: ${w.rationale}\n- Mitigation: ${w.mitigation}\n`).join('\n') : ''}

---

**Ultima sincronizzazione**: ${new Date().toISOString()}
`;

  const filePath = path.join(CONFIG_DIR, 'INSTRUCTIONS.md');
  fs.writeFileSync(filePath, content, 'utf8');
  console.log('✅ INSTRUCTIONS.md generato');
}

// ============================================
// 2. GENERA claude-vscode.json
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
  generateInstructions();
  generateClaudeConfig();
  generateGitHubCopilotConfig();
  
  console.log('\n✨ Sincronizzazione completata!');
  console.log('\n📝 File generati:');
  console.log('  - configurations/INSTRUCTIONS.md');
  console.log('  - configurations/claude-vscode.json');
  console.log('  - configurations/github-copilot-vscode.json');
  console.log('\n💡 Modifica solo base-config.json e riesegui questo script.\n');
  
} catch (error) {
  console.error('❌ Errore durante la sincronizzazione:', error.message);
  process.exit(1);
}
