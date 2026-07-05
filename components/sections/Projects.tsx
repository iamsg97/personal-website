import { Suspense } from "react";
import { Section } from "@/components/Section";
import { ProjectCard } from "@/components/ProjectCard";
import { GithubRepos, RepoSkeleton } from "@/components/GithubRepos";
import { getResume } from "@/lib/resume";
import styles from "./Projects.module.css";

export function Projects() {
  const { projects } = getResume();
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

      <h3 id="git-remote" className={styles.subhead}>
        # git remote — live from github.com/iamsg97
      </h3>
      <Suspense fallback={<RepoSkeleton />}>
        <GithubRepos />
      </Suspense>
    </Section>
  );
}
