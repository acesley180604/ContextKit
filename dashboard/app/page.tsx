import Link from 'next/link';
import { ArrowRight, CheckCircle, Github, Sparkles, Globe, Cpu } from 'lucide-react';

export default function HomePage() {
  return (
    <div className="min-h-screen bg-slate-950">
      {/* Navigation */}
      <nav className="border-b border-slate-800">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center space-x-2">
              <Sparkles className="h-6 w-6 text-emerald-500" />
              <span className="text-xl font-bold">ContextKit</span>
            </div>
            <div className="flex items-center space-x-6">
              <Link href="/dashboard" className="text-slate-300 hover:text-white">
                Dashboard
              </Link>
              <Link href="https://github.com/contextkit/contextkit" className="text-slate-300 hover:text-white flex items-center space-x-2">
                <Github className="h-5 w-5" />
                <span>GitHub</span>
              </Link>
              <Link href="/dashboard" className="bg-emerald-500 text-white px-4 py-2 rounded-lg hover:bg-emerald-600">
                Get API Key
              </Link>
            </div>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-20 pb-16">
        <div className="text-center">
          <h1 className="text-5xl font-bold mb-6 bg-gradient-to-r from-emerald-400 to-emerald-600 bg-clip-text text-transparent">
            Context-Aware Event Tracking<br />+ AI Diagnostics SDK for iOS
          </h1>
          <p className="text-2xl text-slate-400 mb-8 max-w-3xl mx-auto">
            Mixpanel tells you <span className="text-white">what happened</span>.<br />
            We tell you <span className="text-emerald-500">what's wrong and how to fix it</span>.
          </p>

          {/* Code Example */}
          <div className="bg-slate-900 border border-slate-800 rounded-xl p-6 max-w-2xl mx-auto mb-8 text-left">
            <div className="flex items-center space-x-2 mb-4">
              <div className="w-3 h-3 rounded-full bg-red-500"></div>
              <div className="w-3 h-3 rounded-full bg-yellow-500"></div>
              <div className="w-3 h-3 rounded-full bg-green-500"></div>
              <span className="text-slate-500 text-sm ml-2">AppDelegate.swift</span>
            </div>
            <pre className="text-sm">
              <code className="text-slate-300">
                <span className="text-purple-400">import</span> <span className="text-emerald-400">ContextKit</span>{'\n\n'}
                <span className="text-slate-500">// Two lines to start</span>{'\n'}
                <span className="text-blue-400">ContextKit</span>.<span className="text-yellow-300">configure</span>(<span className="text-orange-400">apiKey:</span> <span className="text-green-400">"ck_live_xxx"</span>){'\n\n'}
                <span className="text-slate-500">// Context auto-captured</span>{'\n'}
                <span className="text-blue-400">ContextKit</span>.<span className="text-yellow-300">track</span>(<span className="text-green-400">"paywall_viewed"</span>)
              </code>
            </pre>
          </div>

          <div className="flex justify-center space-x-4">
            <Link href="/dashboard" className="bg-emerald-500 text-white px-6 py-3 rounded-lg hover:bg-emerald-600 flex items-center space-x-2">
              <span>Get Started Free</span>
              <ArrowRight className="h-5 w-5" />
            </Link>
            <Link href="https://github.com/contextkit/contextkit" className="bg-slate-800 text-white px-6 py-3 rounded-lg hover:bg-slate-700 flex items-center space-x-2">
              <Github className="h-5 w-5" />
              <span>Star on GitHub</span>
            </Link>
          </div>
        </div>
      </div>

      {/* Problem Section */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 border-t border-slate-800">
        <h2 className="text-3xl font-bold mb-12 text-center">Why Existing Analytics Fail Indie Developers</h2>
        <div className="grid md:grid-cols-3 gap-8">
          <ProblemCard
            title="Event Overload"
            description="Mixpanel dumps thousands of events without context. You drown in data but lack actionable insights."
          />
          <ProblemCard
            title="No Contextual Awareness"
            description="A user in Tokyo at 11pm has different intent than Berlin at 8am. No SDK captures this automatically."
          />
          <ProblemCard
            title="No Diagnostic Layer"
            description="Current tools tell you WHAT happened, not WHY. You must manually segment data and guess at root causes."
          />
        </div>
      </div>

      {/* Solution Section */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 border-t border-slate-800">
        <h2 className="text-3xl font-bold mb-12 text-center">The 3-Layer Solution</h2>
        <div className="grid md:grid-cols-3 gap-8">
          <FeatureCard
            icon={<Globe className="h-8 w-8 text-emerald-500" />}
            title="Phase 1: Context Engine"
            description="Auto-tag every event with time, geo, device, user segment. Drop-in replacement for Mixpanel with zero config."
            status="Available Now"
          />
          <FeatureCard
            icon={<Cpu className="h-8 w-8 text-emerald-500" />}
            title="Phase 2: AI Diagnostics"
            description={`Analyze patterns across contexts, detect anomalies. "Your signup drops 40% in Germany at night"`}
            status="Coming Soon"
          />
          <FeatureCard
            icon={<Sparkles className="h-8 w-8 text-emerald-500" />}
            title="Phase 3: Benchmark DB"
            description={`Compare against anonymized data from all SDK users. "Top apps convert 2x with social proof in Asia"`}
            status="Roadmap"
          />
        </div>
      </div>

      {/* Comparison Table */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 border-t border-slate-800">
        <h2 className="text-3xl font-bold mb-12 text-center">How We Compare</h2>
        <div className="overflow-x-auto">
          <table className="w-full border border-slate-800">
            <thead>
              <tr className="bg-slate-900">
                <th className="border border-slate-800 px-4 py-3 text-left">Feature</th>
                <th className="border border-slate-800 px-4 py-3 text-center">Mixpanel</th>
                <th className="border border-slate-800 px-4 py-3 text-center">Amplitude</th>
                <th className="border border-slate-800 px-4 py-3 text-center">Superwall</th>
                <th className="border border-slate-800 px-4 py-3 text-center bg-emerald-900/20">ContextKit</th>
              </tr>
            </thead>
            <tbody>
              <ComparisonRow
                feature="Event tracking"
                mixpanel="✓"
                amplitude="✓"
                superwall="Paywall only"
                contextkit="✓"
              />
              <ComparisonRow
                feature="Auto-context collection"
                mixpanel="✗"
                amplitude="✗"
                superwall="✗"
                contextkit="✓"
                highlight
              />
              <ComparisonRow
                feature="Time-aware segmentation"
                mixpanel="Manual"
                amplitude="Manual"
                superwall="✗"
                contextkit="Automatic"
                highlight
              />
              <ComparisonRow
                feature="AI diagnostics"
                mixpanel="✗"
                amplitude="✗"
                superwall="✗"
                contextkit="✓ (Phase 2)"
                highlight
              />
              <ComparisonRow
                feature="Pricing"
                mixpanel="$25+/mo"
                amplitude="$49+/mo"
                superwall="$0-$1500/mo"
                contextkit="Free tier"
              />
            </tbody>
          </table>
        </div>
      </div>

      {/* CTA Section */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 border-t border-slate-800">
        <div className="bg-gradient-to-r from-emerald-500/10 to-emerald-600/10 border border-emerald-500/20 rounded-2xl p-12 text-center">
          <h2 className="text-4xl font-bold mb-4">Ready to Get Started?</h2>
          <p className="text-xl text-slate-400 mb-8">
            Zero permissions required. Two lines of code. Free tier available.
          </p>
          <div className="flex justify-center space-x-4">
            <Link href="/dashboard" className="bg-emerald-500 text-white px-8 py-4 rounded-lg hover:bg-emerald-600 text-lg">
              Get Your API Key
            </Link>
            <Link href="https://github.com/contextkit/contextkit" className="bg-slate-800 text-white px-8 py-4 rounded-lg hover:bg-slate-700 text-lg flex items-center space-x-2">
              <Github className="h-6 w-6" />
              <span>View on GitHub</span>
            </Link>
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="border-t border-slate-800 mt-20">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <div className="flex justify-between items-center">
            <div className="flex items-center space-x-2">
              <Sparkles className="h-5 w-5 text-emerald-500" />
              <span className="font-bold">ContextKit</span>
            </div>
            <div className="text-slate-500 text-sm">
              © 2026 ContextKit. MIT License.
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}

function ProblemCard({ title, description }: { title: string; description: string }) {
  return (
    <div className="bg-slate-900 border border-slate-800 rounded-xl p-6">
      <h3 className="text-xl font-semibold mb-3 text-red-400">{title}</h3>
      <p className="text-slate-400">{description}</p>
    </div>
  );
}

function FeatureCard({
  icon,
  title,
  description,
  status,
}: {
  icon: React.ReactNode;
  title: string;
  description: string;
  status: string;
}) {
  return (
    <div className="bg-slate-900 border border-slate-800 rounded-xl p-6">
      <div className="mb-4">{icon}</div>
      <h3 className="text-xl font-semibold mb-2">{title}</h3>
      <p className="text-slate-400 mb-4">{description}</p>
      <span className="inline-block px-3 py-1 bg-emerald-500/20 text-emerald-400 text-sm rounded-full">
        {status}
      </span>
    </div>
  );
}

function ComparisonRow({
  feature,
  mixpanel,
  amplitude,
  superwall,
  contextkit,
  highlight = false,
}: {
  feature: string;
  mixpanel: string;
  amplitude: string;
  superwall: string;
  contextkit: string;
  highlight?: boolean;
}) {
  const highlightClass = highlight ? 'bg-emerald-900/20' : '';
  return (
    <tr>
      <td className="border border-slate-800 px-4 py-3 font-medium">{feature}</td>
      <td className="border border-slate-800 px-4 py-3 text-center text-slate-400">{mixpanel}</td>
      <td className="border border-slate-800 px-4 py-3 text-center text-slate-400">{amplitude}</td>
      <td className="border border-slate-800 px-4 py-3 text-center text-slate-400">{superwall}</td>
      <td className={`border border-slate-800 px-4 py-3 text-center text-emerald-400 font-semibold ${highlightClass}`}>
        {contextkit}
      </td>
    </tr>
  );
}
