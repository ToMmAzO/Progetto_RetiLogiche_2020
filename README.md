# Prova Finale di Reti Logiche - a.a. 2019-2020
Lo scopo del progetto è di implementare un componente hardware, descritto in VHDL, che, presi in ingresso gli indirizzi base delle otto zone di lavoro e un indirizzo da codificare, trasformi quest’ultimo, nel caso in cui appartenga all’intervallo di una delle zone di lavoro, utilizzando il metodo di codifica a bassa dissipazione di potenza denominato “Working Zone”.

## Definizione del Problema
Gli indirizzi in input sono 9: i primi 8 sono le Working Zone __(WZ)__ e il 9° è l’indirizzo __(ADDR)__ da codificare. Tutti gli ingressi sono a 8 bit. Ogni WZ corrisponde ad un intervallo fisso di 4 indirizzi. Il componente hardware deve codificare un indirizzo in uscita a 8 bit secondo l’algoritmo spiegato meglio nelle [specifiche complete](https://github.com/ToMmAzO/Progetto_RetiLogiche_2020/blob/main/Specifications/PFRL_Specifica_1920.pdf). L'implementazione del componente è stata realizzata interfacciandosi a una __memoria__ contenente tutte le informazioni relative al problema e utilizzando appositi __segnali__.

## Implementazione
L'[implementazione](https://github.com/ToMmAzO/Progetto_RetiLogiche_2020/blob/main/Project_Pozzi_Riva.vhd) del componente consiste principalmete nella realizzazione di una macchina a stati in grado di determinare se l’indirizzo __(ADDR)__ da codificare è presente o meno in una Working Zone.

## Test Bench
L'insieme di test utilizzato per la realizzazione del componente è contenuto all'interno del __[test bench_in](https://github.com/ToMmAzO/Progetto_RetiLogiche_2020/blob/main/tb_pfrl_2020_in_wz.vhd)__ e __[test bench_no](https://github.com/ToMmAzO/Progetto_RetiLogiche_2020/blob/main/tb_pfrl_2020_no_wz.vhd)__. 

L'insieme di test è stato realizzato a partire da quello della specifica andando a identificare i casi che spingono l'esecuzione verso condizioni critiche così da verificare la completa correttezza del sistema, non essendo a disposizione dei test privati utilizzati per la valutazione.

Tra i test sviluppati per sforzare il componente in situazioni particolari, i più significativi vengono chiamati:
  * ADDR in ingresso minimo e non presente in nessuna WZ
  * ADDR in ingresso minimo e presente nella prima WZ
  * ADDR in ingresso massimo e non presente in nessuna WZ
  * ADDR in ingresso massimo e presente nell’ultima WZ
  * Reset asincrono
  * Doppia computazione
  
Infine per poter garantire una maggiore robustezza sono stati utilizzati anche numerosi test randomici in modo tale da cercare di coprire tutti i possibili cammini di esecuzione della macchina a stati.  

## Sviluppatori
[Tommaso Pozzi](https://github.com/ToMmAzO)

[Marco Riva](https://github.com/marcoriva)
