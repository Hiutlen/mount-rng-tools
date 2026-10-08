# Mount RNG — kontrollues në shqip

Ky version lexon strukturën që loja ka ngarkuar në klient dhe shfaq një raport në panel. Raporti ndihmon të identifikohen dosjet dhe modelet për përshtatjen e një auto-farm. **Auto-farm ende nuk është implementuar.**

## Nisja

Në një mjedis klienti që mbështet `game:HttpGet` dhe `loadstring`:

```lua
loadstring(game:HttpGet('https://raw.githubusercontent.com/Hiutlen/mount-rng-tools/refs/heads/main/loader.lua'))()
```

Për provë në Roblox Studio, kopjo përmbajtjen e `loader.lua` në një LocalScript te `StarterPlayer > StarterPlayerScripts` dhe shtyp Play.

## Përdorimi i panelit

1. Prit të përfundojë skanimi.
2. Shtyp **PËRZGJIDH TEKSTIN**, pastaj **Ctrl+C**.
3. Ngjite raportin në bisedën ku po përshtatet scripti.
4. Përdor **SKANO SËRISH** pasi të ndryshosh zonë, ose **MBYLL** për të hequr panelin.

## Çfarë përmban raporti

- Objektet kryesore të Workspace.
- Dosjet dhe modelet me emra që mund të lidhen me mobs dhe luftime.
- Modelet me Humanoid ose AnimationController.
- Emrat e RemoteEvent, RemoteFunction dhe UnreliableRemoteEvent të dukshme.
- Armët dhe mjetet Tool të personazhit dhe çantës.

Scripti krijon vetëm panelin lokal dhe lexon objektet ekzistuese. Nuk dërgon sulme, nuk ndryshon jetët apo lëvizjen e personazhit dhe nuk transmeton raportin në internet.

## Kufijtë e versionit

Ky kod **nuk është testuar brenda Mount RNG ose Xeno**. Nëse loja përdor streaming, raporti përmban vetëm objektet e ngarkuara në atë çast. Modelet kandidate mund të përfshijnë mounts ose personazhe miqësore. Emrat e Remote nuk tregojnë argumentet dhe rregullat e sulmit.

Skanimi kufizohet në 30 000 objekte për shërbim dhe raporti shfaq deri në 120 hyrje për seksion. Ky version nuk ofron fshehje ose garanci kundër zbulimit.
