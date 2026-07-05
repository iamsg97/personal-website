import type { ReactNode } from "react";
import { Prompt } from "./Prompt";
import { Reveal } from "./Reveal";
import styles from "./Section.module.css";

interface SectionProps {
  id: string;
  command: string;
  path?: string;
  children: ReactNode;
}

/** A page section framed as terminal output: a prompt+command heading, then body. */
export function Section({ id, command, path = "~", children }: SectionProps) {
  return (
    <section id={id} className={styles.section} aria-labelledby={`${id}-heading`}>
      <div className="wrap">
        <h2 id={`${id}-heading`} className={styles.heading}>
          <Prompt path={path} command={command} />
        </h2>
        <div className={styles.body}>
          <Reveal>{children}</Reveal>
        </div>
      </div>
    </section>
  );
}
