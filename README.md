# Flutter TodoClient

**Flutter TodoClient** è un'applicazione mobile sviluppata in Flutter che permette la gestione delle attività (todo) in modo semplice ed intuitivo. Il progetto rappresenta una base per sviluppare una todo app moderna, utilizzando le migliori pratiche Flutter.

## Funzionalità

- Visualizza la lista delle attività
- Aggiungi, modifica ed elimina todo
- Segna le attività come completate
- Sincronizzazione locale (e remoto, se implementato)
- Interfaccia semplice e responsive

## Installazione

1. **Clona il repository**:
   ```bash
   git clone https://github.com/pietroconta/flutter-todoclient.git
   cd flutter-todoclient
   ```

2. **Installa le dipendenze**:
   ```bash
   flutter pub get
   ```

3. **Avvia l'app**:
   ```bash
   flutter run
   ```

## Struttura del progetto

```
lib/
  main.dart         # Entry point dell'app
  models/           # Modelli dati (es. Todo)
  screens/          # Schermate principali
  widgets/          # Widget riutilizzabili
  services/         # Logica per interazione dati/local storage/api
```

## Requisiti

- [Flutter](https://docs.flutter.dev/get-started/install) (versione consigliata: 3.0 o superiore)
- Un device o emulatore Android/iOS

## Contribuire

1. Forka il progetto
2. Crea un nuovo branch: `git checkout -b feature/mia-funzionalita`
3. Fai le tue modifiche e committa: `git commit -m "Aggiunta nuova funzionalità"`
4. Push e apri una Pull Request

## Risorse utili

- [Documentazione ufficiale Flutter](https://docs.flutter.dev/)
- [Codelab: Scrivi la tua prima app Flutter](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Esempi pratici Flutter](https://docs.flutter.dev/cookbook)

## Licenza

Questo progetto è distribuito sotto licenza MIT. Vedi il file [LICENSE](LICENSE) per dettagli.

---

Creato con ❤️ da [pietroconta](https://github.com/pietroconta)
