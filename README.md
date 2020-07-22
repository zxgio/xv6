# xv6 - SETI

Questo è un fork di [xv6](https://github.com/mit-pdos/xv6-public) per il corso di [Sistemi dell'Elaborazione e Trasmissione dell'Informazione](https://unige.it/off.f/2020/ins/43095.html)

Alcune cose sono state modificate, in particolare:
- aggiunto comando `poweroff`, e relativa system call, per "spegnere" xv6 (funziona solo con QEMU)
- la pagina 0 non viene mappata
- stdin/out/error sono aperti con i permessi giusti
- lo scheduler non va in busy loop quando non c'è nulla da eseguire

## Software necessario/suggerito (istruzioni per Ubuntu 20.04)

Installate i pacchetti: `build-essential gcc-multilib git cscope ctags qemu-system`

### gdb

Suggerisco l'uso di [GEF](https://github.com/hugsy/gef); potrebbe tornarvi utile il mio [cheat-sheet](https://github.com/zxgio/gdb_gef-cheatsheet)

### liquidprompt

Assolutamente non necessario per xv6, ma visto che alcuni studenti mi hanno chiesto cosa usavo... se volete un prompt più "ricco" su bash/zsh: [liquidprompt](https://github.com/nojhan/liquidprompt)

## Come compilare/lanciare xv6

Una volta clonato questo repository (`git clone https://github.com/zxgio/xv6-SETI.git`) potrete usare:
- `make` (ri)compila xv6, preparando le immagini dei dischi virtuali
- `make clean` cancella i file prodotti da make

e, per mandarlo in esecuzione:
- `./run`, scorciatoia per `\make qemu-nox`, lancia xv6; uscite con `poweroff` oppure con la sequenza `ctrl+A`, seguita da `x`
  - nota: il backslash prima di `make` evita l'espansione dell'alias, nel caso usiate [Generic Colouriser](https://github.com/garabik/grc), per fare in modo che non ci siano ritardi nell'output dovuti al buffering
- `./debug`, scorciatoria per `\make qmeu-nox-gdb`, prepara xv6 per il debugging, per cui dovrete lanciare gdb da un altro terminale
  - se lanciando gdb ottenete: `warning: File "....xv6/.gdbinit" auto-loading has been declined ...`
    aggiungete la direttiva `add-auto-load-safe-path` al vostro `~/.gdbinit` (come suggerito da gdb stesso)

Durante l'esecuzione `ctrl+P`, catturato dalla console di xv6, mostra la lista dei processi.
Invece, `ctrl+A`, seguito da `c`, (dis)attiva la console di QEMU. Dalla console potete uscire dall'emulazione con `q` o, per esempio, vedere la tabella delle pagine con `info mem`.
