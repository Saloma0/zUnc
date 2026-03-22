# 🔧 Hyper UNC Executor Test

Hyper UNC Executor Test é uma suíte completa de testes desenvolvida para avaliar a compatibilidade, estabilidade e recursos de executores Lua/Roblox.
Ela executa automaticamente uma série de verificações em diferentes áreas, fornecendo um relatório detalhado do que é totalmente suportado, parcialmente suportado ou não funcional no executor testado.

# ✅ O que este teste faz?

A ferramenta valida recursos essenciais e avançados utilizados por scripts modernos de Roblox.
Os testes são organizados em categorias, incluindo:

# 📌 Funções Básicas de Lua
- print, warn, type
- loadstring, assert, tratamento de erros
- Corrotinas, manipulação de tabelas, strings, matemática

# 📌 Recursos do Roblox
- Hierarquia do jogo (game, workspace)
- Manipulação de instâncias
- Eventos e serviços (RunService, Players, etc.)
- Física, CFrame, Raycast, Tweening

# ⚙️ Ambiente / Exploit Functions
- getgenv, getrenv, getsenv, getfenv, setfenv
- checkcaller, newcclosure, isluau, setidentity
- Biblioteca e manipulação de threads

# 🧠 Manipulação de Memória & Debug
- getrawmetatable, setrawmetatable, hookfunction, hookmetamethod
- getupvalues, setupvalue, getconstants
- Ferramentas avançadas (debug.getinfo, debug.getstack, etc.)

# 🎨 UI & Drawing
- Funções de drawing
- Interação com mouse/inputs
- Interface dinâmica / ViewportFrame

# 🌐 Rede
- HTTP avançado
- WebSocket (quando disponível)
- Monitoramento de rede e teleporte

# 🗂 Sistema de Arquivos
- Leitura/escrita de arquivos
- Gerenciamento de diretórios

# 📤 Como usar

1. Copie o script do repositório
2. Execute no seu executor Roblox
3. Veja o relatório completo no console (pass/fail, porcentagem e análise)

# 📊 Resultados

O relatório final mostra:

Resultado: ✅ Pass / ⚠️ Parcial / ❌ Fail

Além disso, o executor recebe:
- Pontuação total (%)
- Classificação de desempenho

Pontuação | Classificação
100%      Suporte máximo
80%+      Suporte avançado
50%+      Suporte moderado
<50%      Suporte limitado

# 🧩 Contribuição

Sugestões e melhorias são bem-vindas!
Envie pull requests para novas categorias de teste ou otimizações.

# ⚠️ Aviso

Este projeto é exclusivamente para pesquisa e fins educacionais.
O uso inadequado pode violar os Termos de Serviço do Roblox. Use com responsabilidade.
