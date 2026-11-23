# Profissões e Projeto de Vida — Álbum Digital para o Ensino Médio

Álbum digital pedagógico sobre autoconhecimento, profissões, caminhos de formação, mundo do trabalho e projeto de vida, pensado para estudantes do **Ensino Médio**. Usa a mesma estrutura do álbum **Combate ao Bullying e ao Cyberbullying**, com conteúdo novo.

A escola que aparece no álbum, **Escola Municipal Horizonte Azul**, é **fictícia**. Para usar em uma escola real, troque o nome em `album-data.js` e em `index.html`, e substitua o arquivo `logo-escola.png`.

## Créditos
**Idealização, projeto digital, desenvolvimento do aplicativo e arquitetura da plataforma:** Prof. Carlos André Tavares de Lima
Professor de Geografia • Administração Escolar • Criador de Projetos Digitais Educativos
cincoregioes@gmail.com

## O que tem no álbum
- **36 figurinhas em 6 páginas temáticas**, com 4 raras, 10 especiais e 22 comuns:
  1. Quem sou eu (projeto de vida, autoconhecimento, interesses, talentos, valores, território)
  2. Sonhos, metas e planejamento (sonho x meta, metas SMART, prazos, rotina, plano B, resiliência)
  3. Explorando profissões (saúde, educação, tecnologia e IA, indústria e ofícios técnicos, meio ambiente, economia criativa)
  4. Caminhos da formação (Novo Ensino Médio, curso técnico, ensino superior, Enem/Sisu/cotas, ProUni e Fies, Pé-de-Meia)
  5. Mundo do trabalho e direitos (idade mínima, Jovem Aprendiz, estágio, carteira assinada, igualdade e inclusão, MEI)
  6. Projeto de vida em ação (competências socioemocionais, currículo e entrevista, reputação digital, educação financeira, saúde mental, plano final)
- **Ficha de cada figurinha** com mensagem central, por que isso importa, atitude, **base legal e referência** e uma pergunta para conversar.
- **5 simulados de 10 questões.** Quem acerta 10 ganha 1 pacote; com qualquer erro ganha 1 figurinha. As alternativas corretas são redistribuídas automaticamente.
- **Desafio Final** (10 questões) e **Missão Resgate** (5 situações do dia a dia).
- **Pesquisa 1** (diagnóstico inicial) e **Pesquisa 2** (avaliação final), anônimas, com indicadores de antes e depois: conhecer a si mesmo, conhecer profissões, planejar metas, conhecer caminhos de formação e conhecer direitos do jovem no trabalho.
- **Game match-3** com 5 fases pedagógicas, que revela as figurinhas do álbum e dá prêmios ao álbum.
- **Painel dos professores** (`professor.html`) com login por nome de usuário, impacto antes e depois, ciclos, concluintes e exportação em CSV.
- **PWA** offline e **APK Android**.

## Dados conferidos (23/11/2026)
Os números citados valem para as regras de 2026 e podem mudar. Revise todo ano em `album-data.js`:
- **Novo Ensino Médio** (Lei 14.945/2024): 3.000 h, sendo 2.400 h de formação geral básica e 600 h de itinerários (2.100 h de formação geral na formação técnica).
- **Pé-de-Meia** (Lei 14.818/2024): R$ 200 de matrícula, até 9 parcelas de R$ 200 de frequência, R$ 1.000 por ano concluído e R$ 200 pelo Enem.
- **ProUni / Fies**: média mínima de 450 no Enem e redação acima de zero; renda por pessoa de até 1,5 SM (ProUni integral), 3 SM (ProUni parcial e Fies).
- **Lei de Cotas** (Lei 12.711/2012, com a Lei 14.723/2023): mínimo de 50% das vagas federais para escola pública; metade para renda de até 1 SM por pessoa.
- **Jovem Aprendiz** (CLT, art. 428): 14 a 24 anos, contrato de até 2 anos. **Estágio** (Lei 11.788/2008): até 6 h/dia e 30 h/semana no ensino médio.
- **MEI** (LC 123/2006 com a LC 238/2026): R$ 81 mil até 2026, R$ 110 mil em 2027 e R$ 140 mil a partir de 2028.
- O antigo art. 35-A da LDB (projeto de vida) foi revogado pela Lei 14.945/2024; por isso o álbum fundamenta o projeto de vida na **BNCC, Competência Geral 6**.

## Onde editar o conteúdo
Todo o conteúdo pedagógico (figurinhas, páginas, simulados, desafio, missão, pesquisas, micro-aulas e fases do game) está em **`album-data.js`**.

## Figurinhas
As 36 figurinhas da pasta `figurinhas/` são **artes provisórias** (número, ícone, título e tema, com cor por página e borda por raridade), no formato vertical 9:16 (768×1376 px).
Os prompts para gerar as imagens definitivas estão em **`docs/PROMPTS_FIGURINHAS.md`**. Para trocar uma imagem, salve a nova com o mesmo nome (`01.webp` … `36.webp`). Não é preciso mudar nenhum código.

## Modo livre (padrão) e Supabase
O álbum vem em **modo livre**: tudo funciona sem servidor (álbum, pacotes, simulados, desafio, missões, game e as duas pesquisas) e o progresso de cada aluno fica salvo no próprio aparelho/navegador.

- **Pesquisa 1** (diagnóstico inicial) pode ser respondida a qualquer momento.
- **Pesquisa 2** (avaliação final) é liberada automaticamente quando o aluno **completa o álbum** (36 figurinhas coladas).
- **Identificação do aluno** fica bloqueada com o aviso de que será habilitada após a definição do projeto.

### Para ter o painel dos professores (opcional)
1. Crie um projeto no Supabase e rode `supabase/PROJETO_DE_VIDA_SUPABASE.sql` no SQL Editor.
2. Crie o login de cada professor com o comando que está no fim do arquivo.
3. Em `supabase-config.js`, preencha `url` e a chave pública (`publishableKey` e `anonKey`) e mude `enabled` para `true`. Em `game/game-v13.js`, preencha a mesma `url` e `key`.

## Publicar no GitHub Pages
Em **Settings → Pages**, escolha *Deploy from a branch*, depois a branch `main` e a pasta `/ (root)`.
Endereço: `https://cincoregioes-star.github.io/album-profissoes-projeto-de-vida/`. O QR Code está em `qrcode/`.

## App para usar sem internet
- **Android:** a cada atualização na branch `main`, o GitHub gera o app (`projeto-de-vida.apk`) e publica em **Releases**. O botão **📲 Baixar o app** aponta para
  `https://github.com/cincoregioes-star/album-profissoes-projeto-de-vida/releases/latest/download/projeto-de-vida.apk`.
  Ele é instalado como um app separado dos outros álbuns (`br.com.projetodevida.album`).
- **iPhone/iPad e computador:** o site é um app instalável (PWA). Depois de aberto uma vez com internet, funciona offline.
- A chave de assinatura do app está em `android-wrapper/combate-bullying.keystore` (senha no `app/build.gradle`). Mantenha esse arquivo.
