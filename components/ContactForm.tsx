"use client";

import { useState, type FormEvent } from "react";
import { profile } from "@/content/profile";
import styles from "./ContactForm.module.css";

type Status = "idle" | "sending" | "sent" | "error";

export function ContactForm() {
  const [status, setStatus] = useState<Status>("idle");
  const [feedback, setFeedback] = useState("");
  const [mailto, setMailto] = useState<string | null>(null);

  async function onSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    const form = e.currentTarget;
    const data = Object.fromEntries(new FormData(form)) as Record<string, string>;

    setStatus("sending");
    setFeedback("");
    setMailto(null);

    try {
      const res = await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(data),
      });
      const json = (await res.json().catch(() => ({}))) as { error?: string; fallback?: boolean };

      if (res.ok) {
        setStatus("sent");
        setFeedback("Message sent — thanks. I'll get back to you soon.");
        form.reset();
        return;
      }

      setStatus("error");
      setFeedback(json.error ?? "Something went wrong.");
      if (json.fallback) {
        const subject = encodeURIComponent(`Portfolio contact from ${data.name ?? ""}`);
        const bodyText = encodeURIComponent(data.message ?? "");
        setMailto(`mailto:${profile.email}?subject=${subject}&body=${bodyText}`);
      }
    } catch {
      setStatus("error");
      setFeedback("Network error — try emailing me directly.");
      setMailto(`mailto:${profile.email}`);
    }
  }

  return (
    <form className={styles.form} onSubmit={onSubmit} noValidate>
      <label className={styles.field}>
        <span className={styles.label}>name&gt;</span>
        <input type="text" name="name" autoComplete="name" required maxLength={100} />
      </label>

      <label className={styles.field}>
        <span className={styles.label}>email&gt;</span>
        <input type="email" name="email" autoComplete="email" required maxLength={200} />
      </label>

      <label className={styles.field}>
        <span className={styles.label}>message&gt;</span>
        <textarea name="message" rows={5} required maxLength={5000} />
      </label>

      {/* honeypot: hidden from users, catches bots */}
      <div className={styles.honeypot} aria-hidden="true">
        <label>
          Website
          <input type="text" name="website" tabIndex={-1} autoComplete="off" />
        </label>
      </div>

      <div className={styles.actions}>
        <button type="submit" className={styles.submit} disabled={status === "sending"}>
          {status === "sending" ? "sending…" : "./send"}
        </button>
        <span aria-live="polite" className={status === "error" ? styles.error : styles.ok}>
          {feedback}
          {mailto ? (
            <>
              {" "}
              <a href={mailto}>open mail client →</a>
            </>
          ) : null}
        </span>
      </div>
    </form>
  );
}
