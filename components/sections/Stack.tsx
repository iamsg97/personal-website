import { Section } from "@/components/Section";
import { getResume } from "@/lib/resume";
import styles from "./Stack.module.css";

export function Stack() {
  const { skills, certifications } = getResume();
  return (
    <Section id="stack" command="cat stack.txt">
      <dl className={styles.list}>
        {skills.map((group) => (
          <div key={group.label} className={styles.row}>
            <dt className={styles.key}>{group.label}</dt>
            <dd className={styles.val}>
              {group.items.map((item, i) => (
                <span key={item}>
                  {item}
                  {i < group.items.length - 1 ? <span className={styles.sep}> · </span> : null}
                </span>
              ))}
            </dd>
          </div>
        ))}
      </dl>

      <h3 className={styles.subhead}># certifications</h3>
      <ul className={styles.certs}>
        {certifications.map((c) => (
          <li key={c.name} className={c.done ? styles.done : styles.progress}>
            <span className={styles.marker} aria-hidden="true">
              {c.done ? "✓" : "◷"}
            </span>
            {c.name}
            {c.done ? null : <span className={styles.progressLabel}>— in progress</span>}
          </li>
        ))}
      </ul>
    </Section>
  );
}
