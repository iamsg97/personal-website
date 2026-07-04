import { Section } from "@/components/Section";
import { getResume } from "@/lib/resume";
import styles from "./Experience.module.css";

export function Experience() {
  const { experience } = getResume();
  return (
    <Section id="experience" command="cat experience.log">
      <div className={styles.jobs}>
        {experience.map((job) => (
          <article key={job.company} className={styles.job}>
            <header className={styles.head}>
              <div>
                <span className={styles.company}>{job.company}</span>
                <span className={styles.role}> — {job.role}</span>
              </div>
              <span className={styles.period}>{job.period}</span>
            </header>
            <p className={styles.meta}>
              {job.location}
              {job.note ? ` · ${job.note}` : ""}
            </p>
            <ul className={styles.bullets}>
              {job.highlights.map((h, i) => (
                <li key={i}>
                  <span className={styles.marker} aria-hidden="true">
                    ▸
                  </span>
                  {h}
                </li>
              ))}
            </ul>
          </article>
        ))}
      </div>
    </Section>
  );
}
