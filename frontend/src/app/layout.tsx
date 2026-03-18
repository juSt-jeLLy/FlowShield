import type { Metadata } from "next";
import { Space_Grotesk, Spline_Sans } from "next/font/google";
import "./globals.css";
import { FlowProviderWrapper } from "@/components/flow-provider-wrapper";

const spaceGrotesk = Space_Grotesk({
  variable: "--font-space-grotesk",
  subsets: ["latin"],
});

const splineSans = Spline_Sans({
  variable: "--font-spline-sans",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "FlowShield",
  description: "SlipShield protected swaps on Flow",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${spaceGrotesk.variable} ${splineSans.variable} antialiased`}>
        <FlowProviderWrapper>{children}</FlowProviderWrapper>
      </body>
    </html>
  );
}
