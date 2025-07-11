import { SOCIAL_LINKS } from '../constants/links'
import { SectionContainer } from './SectionContainer'
import { Button } from './ui/button'
import { Card, CardContent, CardHeader, CardTitle } from './ui/card'

export default function Contact() {
  return (
    <section id="contact" className="bg-muted/30 py-16">
      <SectionContainer>
        <h2 className="mb-12 text-center text-3xl font-bold">Get In Touch</h2>

        <div className="mx-auto max-w-2xl">
          <Card>
            <CardHeader>
              <CardTitle className="text-xl">Send Me a Message</CardTitle>
            </CardHeader>
            <CardContent>
              <form className="space-y-4">
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                  <div className="space-y-2">
                    <label htmlFor="name" className="text-sm font-medium">
                      Name
                    </label>
                    <input
                      id="name"
                      className="focus:ring-accent/30 w-full rounded-md border px-3 py-2 focus:ring-2 focus:outline-none"
                      placeholder="Your name"
                      type="text"
                      required
                    />
                  </div>
                  <div className="space-y-2">
                    <label htmlFor="email" className="text-sm font-medium">
                      Email
                    </label>
                    <input
                      id="email"
                      className="focus:ring-accent/30 w-full rounded-md border px-3 py-2 focus:ring-2 focus:outline-none"
                      placeholder="Your email"
                      type="email"
                      required
                    />
                  </div>
                </div>
                <div className="space-y-2">
                  <label htmlFor="subject" className="text-sm font-medium">
                    Subject
                  </label>
                  <input
                    id="subject"
                    className="focus:ring-accent/30 w-full rounded-md border px-3 py-2 focus:ring-2 focus:outline-none"
                    placeholder="Message subject"
                    type="text"
                    required
                  />
                </div>
                <div className="space-y-2">
                  <label htmlFor="message" className="text-sm font-medium">
                    Message
                  </label>
                  <textarea
                    id="message"
                    className="focus:ring-accent/30 min-h-[150px] w-full rounded-md border px-3 py-2 focus:ring-2 focus:outline-none"
                    placeholder="Your message"
                    required
                  />
                </div>
                <Button type="submit" className="w-full sm:w-auto">
                  Send Message
                </Button>
              </form>
            </CardContent>
          </Card>

          <div className="mt-10 grid grid-cols-1 gap-4 text-center sm:grid-cols-3">
            <div className="p-4">
              <div className="bg-accent/10 mb-3 inline-flex items-center justify-center rounded-full p-3">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  strokeWidth={1.5}
                  stroke="currentColor"
                  className="text-accent h-6 w-6"
                >
                  <title>Email icon</title>
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75"
                  />
                </svg>
              </div>
              <h3 className="text-lg font-semibold">Email</h3>
              <p className="mt-1">
                <a href={SOCIAL_LINKS.email} className="hover:text-accent">
                  example@domain.com
                </a>
              </p>
            </div>

            <div className="p-4">
              <div className="bg-accent/10 mb-3 inline-flex items-center justify-center rounded-full p-3">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  strokeWidth={1.5}
                  stroke="currentColor"
                  className="text-accent h-6 w-6"
                >
                  <title>Location icon</title>
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"
                  />
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"
                  />
                </svg>
              </div>
              <h3 className="text-lg font-semibold">Location</h3>
              <p className="mt-1">San Francisco, CA</p>
            </div>

            <div className="p-4">
              <div className="bg-accent/10 mb-3 inline-flex items-center justify-center rounded-full p-3">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  fill="none"
                  viewBox="0 0 24 24"
                  strokeWidth={1.5}
                  stroke="currentColor"
                  className="text-accent h-6 w-6"
                >
                  <title>Phone icon</title>
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    d="M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 0 0 2.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106c-.44-.11-.902.055-1.173.417l-.97 1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 0 1-7.143-7.143c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 3.102a1.125 1.125 0 0 0-1.091-.852H4.5A2.25 2.25 0 0 0 2.25 4.5v2.25Z"
                  />
                </svg>
              </div>
              <h3 className="text-lg font-semibold">Phone</h3>
              <p className="mt-1">
                <a href={SOCIAL_LINKS.phone} className="hover:text-accent">
                  (123) 456-7890
                </a>
              </p>
            </div>
          </div>
        </div>
      </SectionContainer>
    </section>
  )
}
