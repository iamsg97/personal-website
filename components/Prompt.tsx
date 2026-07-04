import { profile } from "@/content/profile";
import styles from "./Prompt.module.css";

interface PromptProps {
  path?: string;
  command?: string;
}

/** Renders a shell prompt line: `suvadeep@web:~/path $ command`. */
export function Prompt({ path = "~", command }: PromptProps) {
  return (
    <span className={styles.prompt}>
      <span className={styles.user}>{profile.handle}</span>
      <span className={styles.at}>@{profile.host}</span>
      <span className={styles.sep}>:</span>
      <span className={styles.path}>{path}</span>
      <span className={styles.dollar}> $</span>
      {command ? <span className={styles.command}> {command}</span> : null}
    </span>
  );
}
