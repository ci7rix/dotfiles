# dotfiles

Configuration de mon Mac, appliquée par [mise](https://mise.jdx.dev).
But : réinitialiser le poste à tout moment et retrouver un environnement propre en une commande.
Tout est idempotent : chaque commande peut être relancée sans rien casser.

## Nouveau Mac ou Mac réinitialisé

Dans le Terminal, après l'assistant de configuration de macOS :

```sh
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ci7rix/dotfiles/main/bootstrap.sh)"
```

Le script installe les Command Line Tools (git) et mise, clone ce repo dans `~/Developer/github.com/ci7rix/dotfiles`, applique tout, puis lance `mise run setup`.

Ensuite, à la main :

1. Se déconnecter et se reconnecter (fish devient le shell de connexion).
2. Ajouter sur GitHub et sur les serveurs la clé SSH affichée par `setup`.
3. Ajouter au `.sops.yaml` le destinataire age affiché par `setup`, puis lancer `sops updatekeys` depuis un Mac qui déchiffre déjà (ou avec la clé de secours).
4. Accepter les autorisations de Karabiner-Elements et d'OmniWM, et les mettre à l'ouverture de session avec Maccy et KeepingYouAwake.

## Tâches

Dans le repo, `mise trust` une fois, puis `mise run` pour choisir dans la liste.

| Tâche | Rôle |
|---|---|
| `apply` | Applique la config : paquets, dotfiles, réglages macOS, shell, outils. `--only dotfiles,defaults` pour une partie |
| `update` | Récupère le repo, l'applique, puis met à jour paquets, outils mise, plugins fish et Neovim |
| `setup` | Ce qui est propre à ce Mac : Touch ID pour `sudo`, clé SSH et clé age dans la Secure Enclave. Garde ce qui existe |
| `reset` | Repart de zéro pour les dotfiles : liens, plugins fish et Neovim, serveur tmux. Ne touche pas au reste de `~/.config` |
| `check` | Teste la config dans un HOME temporaire, sans rien installer |
| `release` | Lance `check`, pose un tag daté sur le commit et le pousse : un état connu bon où revenir |

`apply` et `reset` acceptent `--dry-run` pour voir avant d'agir.
Un fichier qui occupe la place d'un dotfile n'est jamais supprimé : il est déplacé dans `~/.local/state/dotfiles/backup/<date>/`.

## Ajouter quelque chose

Une seule façon de faire par type, puis `mise run apply` :

| Quoi | Où | Comment |
|---|---|---|
| Outil en ligne de commande | `.config/mise/conf.d/10-homebrew.toml` | `"brew:nom" = "latest"`, dans l'ordre alphabétique |
| App | `.config/mise/conf.d/10-homebrew.toml` | `"brew-cask:nom" = { os = "macos" }`, dans l'ordre alphabétique |
| Outil dont mise gère la version | `.config/mise/conf.d/30-tools.toml` | `nom = "latest"` |
| Réglage macOS | `.config/mise/conf.d/20-macos-defaults.toml` | Une ligne dans la table de son domaine |
| Extension ou réglage Firefox | `.config/mise/conf.d/40-firefox.toml` | Une ligne par extension, avec son ID (`about:support`), ou une ligne dans la table du réglage. Redémarrer Firefox, vérifier dans `about:policies` |
| Dotfile | `.config/…` dans le repo | Plus une ligne `"~/.config/…" = {}` dans `[dotfiles]` de `.config/mise/mise.toml` |
| Alias | `.config/fish/config.fish` | `alias nom commande`, dans le bloc des alias |
| Plugin fish | `.config/fish/fish_plugins` | Une ligne `auteur/plugin`, puis `mise run update` |
| Réglage propre à un Mac (clé, secret) | `mise-tasks/setup` | Une fonction qui vérifie avant d'agir, appelée par `try` |
| Tâche | `mise-tasks/nom` | Script bash exécutable qui charge `.lib.sh` |

## Clé de secours sops

Une seule fois : `age-keygen -o backup.txt`, ajouter sa clé publique au `.sops.yaml`, ranger le fichier hors ligne et l'effacer du Mac. Elle sert si tous les Macs sont perdus.
