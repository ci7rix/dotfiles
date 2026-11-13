# dotfiles

Configuration de mon Mac, appliquée par [mise](https://mise.jdx.dev) (`mise bootstrap`).
Objectif : pouvoir réinitialiser le poste à tout moment et retrouver un environnement propre en une commande.

## Contenu

| Élément | Fichiers |
|---|---|
| Paquets Homebrew (formules et casks) | `.config/mise/conf.d/10-homebrew.toml` |
| Réglages macOS (Finder, Dock, clavier, nom de la machine...) | `.config/mise/conf.d/20-macos-defaults.toml` |
| Liens des dotfiles, shell de connexion | `.config/mise/mise.toml` |
| fish (fisher, Rosé Pine, fonction `k`) | `.config/fish/` |
| Ghostty, tmux, Neovim, Starship | `.config/ghostty/`, `.config/tmux/`, `.config/nvim/`, `.config/starship/` |
| Karabiner, OmniWM | `.config/karabiner/`, `.config/omniwm/` |
| Tâches mise | `mise-tasks/` |

## Nouveau Mac ou Mac réinitialisé

1. Terminer l'assistant de configuration de macOS et ouvrir le Terminal.
2. Lancer :

   ```sh
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/ci7rix/dotfiles/main/bootstrap.sh)"
   ```

3. Se déconnecter puis se reconnecter (fish devient le shell de connexion).
4. Suivre la liste [Après l'installation](#après-linstallation).

`bootstrap.sh` fait trois choses :

1. installe les Xcode Command Line Tools (dont git) via `softwareupdate`, sans la fenêtre d'installation ; si ça échoue, il ouvre la fenêtre et attend la fin ;
2. installe mise dans `~/.local/bin` ;
3. lance `mise bootstrap --from https://github.com/ci7rix/dotfiles --config-dir .config/mise --yes` : le repo est cloné dans `~/.local/share/mise/bootstrap-repo` (le `dotfiles.root` de la config), `~/.config/mise` devient un lien vers son dossier `.config/mise`, puis tout est appliqué.

Le mot de passe administrateur est demandé une fois au début.
Pour un aperçu sans rien appliquer, ajouter les arguments après le script : `bash -c "$(curl ...)" -- --dry-run`.

## Au quotidien

Une fois dans le repo, `mise trust` (une seule fois), puis `mise run` affiche la liste des tâches :

| Tâche | Rôle |
|---|---|
| `check` | Teste la config dans un HOME temporaire : config mise, liens, syntaxe fish/tmux/Neovim/Starship/Ghostty/Karabiner, `bootstrap.sh` |
| `bootstrap:dry-run` | Montre ce que le bootstrap changerait |
| `bootstrap:all` | Applique tout |
| `bootstrap:status` | Montre ce qui est appliqué et ce qui diffère |
| `bootstrap:update` | Met à jour le clone et applique le nouveau commit |
| `bootstrap:dotfiles` | Seulement les liens des dotfiles |
| `bootstrap:packages` | Seulement les paquets Homebrew |
| `bootstrap:defaults` | Seulement les réglages macOS, puis relance Finder, le Dock et la barre des menus |

Les arguments supplémentaires passent à mise : `mise run bootstrap:defaults -- --dry-run`.

## Avant de réinitialiser

- `mise run check` passe sans erreur.
- Tout est commité et poussé sur GitHub : le Mac réinitialisé clone `main`.
- Les données (documents, projets non poussés, exports) sont sauvegardées ailleurs : ce repo ne contient que la configuration.

## Après l'installation

Ce que le bootstrap ne peut pas faire :

- **Git** : nom, e-mail et signature des commits (pas de config git dans ce repo).
- **Clés SSH** : les clés Secretive vivent dans la Secure Enclave et disparaissent avec la réinitialisation. En créer de nouvelles dans Secretive et les ajouter sur GitHub.
- **Autorisations macOS** : Karabiner-Elements (extension système, surveillance de l'entrée) et OmniWM (accessibilité) les demandent au premier lancement.
- **Ouverture à la connexion** : OmniWM, Maccy, KeepingYouAwake.
- **Apps du Mac App Store** : non gérées ici.

## Notes

- Finder : vue liste, groupée par type ; le hook des réglages macOS supprime les `.DS_Store` du Bureau, de Documents et de Téléchargements pour que tous les dossiers suivent ces réglages.
- tmux n'utilise aucun plugin : la barre prend les couleurs de la palette de Ghostty et suit donc le thème clair ou sombre en direct.
- Neovim remplace vim : `vi` et `vim` lancent `nvim`. Le thème Rosé Pine est installé par `vim.pack` (intégré à Neovim 0.12) au premier lancement ; le fichier `.config/nvim/nvim-pack-lock.json` qu'il crée fixe la version du thème et se commite avec le reste.
