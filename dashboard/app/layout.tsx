import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'ContextKit - Context-Aware Analytics for iOS',
  description: 'Mixpanel tells you what happened. We tell you what\'s wrong and how to fix it.',
  keywords: ['analytics', 'iOS', 'context', 'AI', 'insights'],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className="dark">
      <body className="bg-slate-950 text-slate-100">
        {children}
      </body>
    </html>
  );
}
