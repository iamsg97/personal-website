import { Suspense } from "react";
import { Section } from "@/components/Section";
import { ProjectCard } from "@/components/ProjectCard";
import { GithubRepos } from "@/components/GithubRepos";
import { projects } from "@/content/projects";
import styles from "./Projects.module.css";

export function Projects() {
  return (
    <Section id="projects" command="ls -la projects/">
      <p className={styles.intro}>
        <span className={styles.comment}>
          # Selected work from LTIMindtree — production systems, mostly under NDA.
        </span>
      </p>
      <div className={styles.grid}>
        {projects.map((p) => (
          <ProjectCard key={p.name} project={p} />
        ))}
      </div>

      <h3 className={styles.subhead}># git remote — live from github.com/iamsg97</h3>
      <Suspense fallback={<p className={styles.loading}>fetching repos…</p>}>
        <GithubRepos />
      </Suspense>
    </Section>
  );
}
