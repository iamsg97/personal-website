export interface UsesGroup {
  label: string;
  items: string[];
}

export const usesRepo = "https://github.com/iamsg97/dotfiles";

export const usesIntro =
  "I live in the terminal. My setup is a one-shot, idempotent `setup.sh` — keyboard-driven, no GUI dependencies, and re-runnable without breaking anything. It's all in my dotfiles.";

export const uses: UsesGroup[] = [
  {
    label: "os",
    items: ["Pop!_OS / Ubuntu 24.04"],
  },
  {
    label: "shell",
    items: ["Fish", "Starship prompt", "Tmux"],
  },
  {
    label: "editor",
    items: ["Neovim", "lazy.nvim", "LSP everywhere"],
  },
  {
    label: "files & git",
    items: ["Yazi", "LazyGit", "Delta", "Gitsigns"],
  },
  {
    label: "toolchains",
    items: [
      "pyenv · uv · ruff",
      "rustup · rust-analyzer",
      "fnm (Node/TS)",
      "OpenJDK 21 · jdtls",
      "Go · gopls",
    ],
  },
];
