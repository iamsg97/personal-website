import { Section } from "@/components/Section";
import { profile, aspirations, type AspirationPart } from "@/content/profile";
import styles from "./About.module.css";

function renderPart(part: AspirationPart, key: number) {
  if (typeof part === "string") return <span key={key}>{part}</span>;
  if (part.external) {
    return (
      <a key={key} href={part.href} target="_blank" rel="noreferrer noopener">
        {part.text}
      </a>
    );
  }
  return (
    <a key={key} href={part.href}>
      {part.text}
    </a>
  );
}

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
        {aspirations.map((item, i) => (
          <li key={i}>
            <span className={styles.box} aria-hidden="true">
              - [ ]
            </span>
            {item.parts.map((part, j) => renderPart(part, j))}
          </li>
        ))}
      </ul>
    </Section>
  );
}
