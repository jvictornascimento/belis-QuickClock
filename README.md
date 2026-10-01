# QuickClock Flutter

Aplicativo Flutter original do QuickClock. Ele funciona como referencia funcional
do produto e como versao mobile/local que ja validou as regras principais.

## Por que existem 3 projetos?

Este app nasceu em Flutter porque a ideia inicial era ter uma unica base para
Android e iOS. Depois ficou claro que publicar ou usar uma versao iOS instalada
fora do modo desenvolvimento exigiria a conta Apple Developer de US$ 99 por ano.

Como este e um app pessoal, nao comercial, nao faz sentido pagar esse valor todo
ano so para usar no proprio celular. Por isso a evolucao principal sera uma PWA:
ela roda no iPhone pelo Safari, pode ser adicionada a tela inicial e nao depende
da App Store.

Entao a divisao fica assim:

- `pabelis-quickclock-flutter`: app Flutter atual e referencia funcional.
- `pabelis-quickclock-front`: frontend React PWA para uso diario.
- `pabelis-quickclock-backend`: backend Spring para API, dados e relatorios.

Nao sao tres projetos por desorganizacao; sao tres papeis diferentes para manter
o app pessoal simples de usar, evoluir e instalar.

## Problema que resolve

O QuickClock controla dias trabalhados em empresas onde presto servico como
tecnico em eletronica. O foco nao e bater horario exato, mas registrar se houve
trabalho antes do almoco, depois do almoco, ou nos dois periodos.

Isso facilita conferir os dias trabalhados, servicos adicionais, orcamentos
aprovados e valores a receber no fechamento do mes.

## Funcionalidades atuais

- Registro offline por periodo: manha e tarde.
- Autosave ao tocar nos botoes da tela inicial.
- Edicao permitida somente no dia atual.
- Configuracao do valor de meio dia.
- Configuracao dos dias da semana com expediente.
- Pesquisa de dias trabalhados.
- Cadastro de servicos adicionais.
- Fluxo de orcamentos e aprovacao.
- Relatorio mensal por empresa.
- Exportacao, importacao e compartilhamento de PDF.

## Estrutura

```text
lib/         Codigo Dart do app
test/        Testes automatizados
android/     Projeto host Android
local_seed/  Cargas locais de desenvolvimento
```

## Comandos

```bash
flutter pub get
flutter run
flutter analyze
flutter test
flutter build apk --release
```

## Contexto compartilhado

As regras de produto ficam em `PROJECT_CONTEXT.md`. Quando ele mudar aqui,
tambem deve ser atualizado nos projetos:

- `/mnt/z/Spring/QuickClock`
- `/mnt/z/react/QuickClock`
