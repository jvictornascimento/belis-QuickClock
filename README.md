# QuickClock

Mini aplicativo de ponto offline feito em Flutter para controle simples de dias trabalhados.

## Problema que o projeto resolve

Eu presto alguns servicos como tecnico em eletronica para uma empresa e preciso ir presencialmente ao local junto com outro funcionario. Na pratica, o controle dos dias trabalhados precisava ser simples, rapido e facil de conferir no fim do mes.

O problema principal nao e controlar horario exato de entrada e saida. O que realmente precisa ser conferido e se houve trabalho antes do almoco, depois do almoco, ou nos dois periodos. Com isso, eu e meu colega conseguimos validar os dias trabalhados sem depender de planilhas soltas, conversas antigas ou anotacoes manuais.

## Como o app resolve

O app salva tudo em um banco SQLite local, funcionando offline no celular. Na tela inicial existem dois botoes grandes: um para o periodo da manha e outro para o periodo da tarde. Cada botao funciona como um marcador booleano: cinza quando nao trabalhou e vermelho quando trabalhou.

O ponto so pode ser alterado no proprio dia, ate 23:59. Dias antigos ficam apenas para consulta, evitando mudancas acidentais depois do fechamento. A tela de configuracao permite definir o valor de meio dia e quais dias da semana tem expediente. Se o dia atual nao for um dia de expediente, o app nao mostra os botoes de ponto e exibe a mensagem de folga.

No relatorio mensal, o app mostra somente as datas que possuem ponto marcado, calcula a quantidade de periodos trabalhados e soma o valor total com base no valor configurado. Tambem e possivel registrar servicos adicionais com data, descricao e valor, que entram no fechamento do mes. O relatorio pode ser visualizado e compartilhado em PDF.

## Funcionalidades atuais

- Registro offline por periodo: manha e tarde.
- Autosave ao tocar nos botoes da tela inicial.
- Edicao permitida somente no dia atual.
- Configuracao do valor de meio dia.
- Configuracao dos dias da semana com expediente.
- Pesquisa de dias trabalhados.
- Cadastro de servicos adicionais.
- Relatorio mensal limpo, apenas com datas marcadas.
- Calculo de total mensal com pontos e servicos adicionais.
- Exportacao e importacao de backup do banco local.
- Visualizacao e compartilhamento de relatorio em PDF.

## Tecnologia

O projeto usa Flutter porque precisa atender Android e iOS com a mesma base de codigo. Hoje o foco de execucao e Android, mas a implementacao deve evitar codigo nativo especifico sempre que possivel para manter o app fiel entre as duas plataformas.

Principais dependencias:

- `sqflite` para banco de dados local.
- `pdf` e `printing` para gerar e visualizar relatorios.
- `share_plus` para compartilhar arquivos.
- `file_selector` para importar backups.

## Estrutura do projeto

```text
lib/
  data/          Repositorios e acesso ao banco SQLite
  features/      Telas e regras por funcionalidade
  models/        Modelos de dados
  shared/        Utilitarios reutilizaveis
test/            Testes automatizados
android/         Projeto host Android
local_seed/      Carga local de desenvolvimento
```

## Comandos de desenvolvimento

Instale as dependencias:

```bash
flutter pub get
```

Execute no dispositivo ou emulador:

```bash
flutter run
```

Rode as verificacoes antes de fechar uma branch:

```bash
flutter analyze
flutter test
```

Gere um APK de release:

```bash
flutter build apk --release
```

## Proximas evolucoes planejadas

O app deve evoluir para suportar varias empresas. Cada empresa tera seus proprios dias trabalhados, valor de diaria, servicos adicionais e relatorios separados. Tambem esta planejado um fluxo de orcamentos: o orcamento fica salvo como historico, pode ser aprovado depois e, quando aprovado, entra no relatorio do mes correspondente.
