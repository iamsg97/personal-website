import { Section } from "@/components/Section";
import { profile } from "@/content/profile";
import styles from "./About.module.css";

export function About() {
  return (
    <Section id="about" command="cat about.md">
      <div className={styles.prose}>
        {profile.about.map((para, i) => (
          <p key={i}>{para}</p>
        ))}
      </div>

      <h3 className={styles.subhead}># aspirations</h3>
      <ul className={styles.todo}>
        {profile.aspirations.map((item, i) => (
          <li key={i}>
            <span className={styles.box} aria-hidden="true">
              - [ ]
            </span>
            {item}
          </li>
        ))}
      </ul>
    </Section>
  );
}
