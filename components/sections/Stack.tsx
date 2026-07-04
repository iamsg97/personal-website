import { Section } from "@/components/Section";
import { skills, certifications } from "@/content/skills";
import styles from "./Stack.module.css";

export function Stack() {
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
          <li key={c}>
            <span className={styles.check} aria-hidden="true">
              ✓
            </span>
            {c}
          </li>
        ))}
      </ul>
    </Section>
  );
}
