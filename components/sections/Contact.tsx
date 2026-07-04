import { Section } from "@/components/Section";
import { ContactForm } from "@/components/ContactForm";
import { profile } from "@/content/profile";
import styles from "./Contact.module.css";

export function Contact() {
  return (
    <Section id="contact" command="./contact.sh">
      <p className={styles.intro}>
        Open to interesting problems, senior/lead roles, and consulting on secure, AI-augmented
        systems. Drop a line — or reach me directly:
      </p>

      <ul className={styles.direct}>
        <li>
          <span className={styles.key}>email</span>
          <a href={`mailto:${profile.email}`}>{profile.email}</a>
        </li>
        {profile.socials.map((s) => (
          <li key={s.label}>
            <span className={styles.key}>{s.label}</span>
            <a href={s.href} target="_blank" rel="noreferrer noopener">
              {s.href.replace("https://", "")}
            </a>
          </li>
        ))}
        <li>
          <span className={styles.key}>résumé</span>
          <a href={profile.resumeUrl} target="_blank" rel="noreferrer noopener">
            download PDF ↓
          </a>
        </li>
      </ul>

      <ContactForm />
    </Section>
  );
}
