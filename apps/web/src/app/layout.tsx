import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'Nebula',
  description: 'Nebula social network',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="fr">
      <body>{children}</body>
    </html>
  );
}
