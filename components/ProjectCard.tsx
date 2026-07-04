import type { Project } from "@/lib/resume";
import styles from "./ProjectCard.module.css";

export function ProjectCard({ project }: { project: Project }) {
  return (
    <article className={styles.card}>
      <header className={styles.head}>
        <h3 className={styles.name}>
          <span className={styles.marker} aria-hidden="true">
            ▸{" "}
          </span>
          {project.name}
          {project.subtitle ? <span className={styles.subtitle}> {project.subtitle}</span> : null}
        </h3>
        <span className={styles.year}>{project.year}</span>
      </header>
      <p className={styles.role}>{project.role}</p>
      <p className={styles.blurb}>{project.blurb}</p>
      <ul className={styles.stack}>
        {project.stack.map((tech) => (
          <li key={tech} className={styles.tag}>
            {tech}
          </li>
        ))}
      </ul>
    </article>
  );
}
