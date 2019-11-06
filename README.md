# xv6 - SETI

Questo è un fork di [xv6](https://github.com/mit-pdos/xv6-public) per il corso di [Sistemi dell'Elaborazione e Trasmissione dell'Informazione](https://unige.it/off.f/2019/ins/36495)

Alcune cose sono state modificate, in particolare:
- aggiunto comando `poweroff`, e relativa system call, per "spegnere" xv6 (funziona solo con QEMU)
- la pagina 0 non viene mappata
- stdin/out/error sono aperti con i permessi giusti
- lo scheduler non va in busy loop quando non c'è nulla da eseguire

## Software necessario/suggerito (istruzioni per Ubuntu 18.04)

Installate i pacchetti: `build-essential gcc-multilib libsdl1.2-dev libtool-bin libglib2.0-dev libz-dev libp
ixman-1-dev git cscope wget`

### gdb

La versione di default è bacata, conviene ricompilarsi una versione più recente; per esempio:
```
mkdir -p /tmp/gdb-src && cd /tmp/gdb-src
wget https://ftp.gnu.org/gnu/gdb/gdb-8.3.1.tar.xz
tar xf gdb-8.3.1.tar.xz
cd gdb-8.3.1/
./configure --prefix=$HOME/bin/gdb8.3.1 --program-suffix=831 --with-python=/usr/bin/python3
make && make install
rm -rf /tmp/gdb-src
```

inoltre, suggerisco l'uso di [GEF](https://github.com/hugsy/gef); potrebbe tornarvi utile il mio [cheat-sheet](https://github.com/zxgio/gdb_gef-cheatsheet)

### qemu

La versione di default è un po' vecchiotta, potete compilare la più recente con qualcosa tipo:

```
git clone https://git.qemu.org/git/qemu.git qemu-src
cd qemu-src
git submodule init
git submodule update --recursive
./configure --prefix=$HOME/bin/qemu
make -j4 && make install
```

...andatevi a prendere un caffè, ci vorrà un po' ;)

Poi settate la variable d'ambiente XV6_SETI_QEMU_HOME (vedi Makefile) e PATH


### liquidprompt

Assolutamente non necessario per xv6, ma visto che alcuni studenti mi hanno chiesto cosa usavo... se volete un prompt più "ricco" su bash/zsh: [liquidprompt](https://github.com/nojhan/liquidprompt)

## Come compilare/lanciare xv6

Una volta clonato questo repository (`git clone https://github.com/zxgio/xv6-SETI.git`) potrete usare:
- `make` (ri)compila xv6, preparando le immagini dei dischi virtuali
- `make qemu-nox` lancia xv6; uscite con `poweroff` oppure con la sequenza `ctrl-A`, seguita da `x`
- `make qmeu-nox-gdb` prepara xv6 per il debugging, per cui dovrete lanciare gdb da un altro terminale
  - se lanciando gdb ottenete: `warning: File "....xv6/.gdbinit" auto-loading has been declined ...`
    aggiungete la direttiva `add-auto-load-safe-path` al vostro `~/.gdbinit` (come suggerito da gdb stesso)
- `make clean` cancella i file prodotti da make
    
se ricompilate QEMU vi conviene impostare la variabile d'ambiente XV6_SETI_QEMU_HOME (vedi Makefile)
