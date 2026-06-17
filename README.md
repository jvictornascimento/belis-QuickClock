# Ponto Eletronico

Mini aplicativo de ponto offline feito em Flutter.

## Contexto

Este projeto resolve uma necessidade pratica de uma empresa onde faco alguns freelas como tecnico em eletronica. Como eu preciso ir presencialmente ate a empresa junto com outro funcionario, criei este app para que eu e meu colega de trabalho possamos conferir melhor quais dias foram trabalhados.

A ideia nao e controlar horario de entrada e saida. O app registra apenas se houve trabalho antes do almoco e/ou depois do almoco. Isso deixa o fluxo simples e suficiente para conferir os dias trabalhados e gerar um relatorio mensal.

Escolhi Flutter porque eu uso iOS e meu colega usa Android. Assim, o mesmo codigo pode atender os dois ambientes com pouca dependencia de codigo nativo especifico.

## Funcionalidades

- Dados locais offline.
- Dois periodos por dia: antes do almoco e depois do almoco.
- Botoes grandes com autosave na tela inicial.
- Edicao permitida somente no dia atual.
- Tela de configuracao para valor de meio dia e dias de expediente.
- Sabado e domingo podem ficar desativados.
- Dias sem expediente mostram a mensagem de folga na home.
- Pesquisa por data ou mes.
- Relatorio mensal apenas com dias marcados e total em dinheiro.
- Visualizacao e compartilhamento de relatorio em PDF.

## Desenvolvimento

Instale as dependencias:

```bash
flutter pub get
```

Rode as verificacoes:

```bash
flutter analyze
flutter test
```

Execute em um dispositivo ou emulador Android:

```bash
flutter run
```

Gere um APK debug:

```bash
flutter build apk --debug
```
