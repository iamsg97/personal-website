export interface SectionMeta {
  id: string;
  label: string; // nav label
  command: string; // shown as the terminal-style section heading
}

export const sections: SectionMeta[] = [
  { id: "about", label: "about", command: "cat about.md" },
  { id: "experience", label: "experience", command: "cat experience.log" },
  { id: "projects", label: "projects", command: "ls -la projects/" },
  { id: "stack", label: "stack", command: "cat stack.txt" },
  { id: "uses", label: "uses", command: "cat ~/.dotfiles" },
  { id: "contact", label: "contact", command: "./contact.sh" },
];
