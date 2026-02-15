'use client';

import { useState } from 'react';
import { Card, Title, Text, BarChart, DonutChart, Metric } from '@tremor/react';
import { Activity, Globe, Clock, Smartphone, Users } from 'lucide-react';

export default function DashboardPage() {
  const [selectedApp] = useState('demo-app');
  const [dateRange] = useState('7d');

  // Mock data
  const eventsByCountry = [
    { country: 'US', events: 1234 },
    { country: 'JP', events: 891 },
    { country: 'DE', events: 567 },
    { country: 'GB', events: 445 },
    { country: 'FR', events: 334 },
  ];

  const eventsByDayPeriod = [
    { period: 'Morning', events: 856, conversion: 12.3 },
    { period: 'Afternoon', events: 1234, conversion: 15.7 },
    { period: 'Evening', events: 1567, conversion: 18.2 },
    { period: 'Night', events: 543, conversion: 8.9 },
  ];

  const recentEvents = [
    { name: 'paywall_viewed', count: 1234, time: '2m ago', country: 'US' },
    { name: 'purchase_completed', count: 89, time: '5m ago', country: 'JP' },
    { name: 'onboarding_completed', count: 234, time: '8m ago', country: 'DE' },
    { name: 'screen_view', count: 3456, time: '1m ago', country: 'GB' },
  ];

  return (
    <div className="min-h-screen bg-slate-950 p-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-white mb-2">Dashboard</h1>
        <p className="text-slate-400">Context-aware analytics for your iOS app</p>
      </div>

      {/* Top Stats */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <StatCard
          title="Total Events"
          value="12,345"
          icon={<Activity className="h-5 w-5" />}
          change="+23%"
        />
        <StatCard
          title="Active Users"
          value="1,234"
          icon={<Users className="h-5 w-5" />}
          change="+12%"
        />
        <StatCard
          title="Countries"
          value="48"
          icon={<Globe className="h-5 w-5" />}
          change="+5"
        />
        <StatCard
          title="Avg Session"
          value="4.2m"
          icon={<Clock className="h-5 w-5" />}
          change="+8%"
        />
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <Card className="bg-slate-900 border-slate-800">
          <Title className="text-white">Events by Country</Title>
          <Text className="text-slate-400">Top 5 countries by event volume</Text>
          <BarChart
            className="mt-6 h-64"
            data={eventsByCountry}
            index="country"
            categories={['events']}
            colors={['emerald']}
            valueFormatter={(value) => `${value} events`}
          />
        </Card>

        <Card className="bg-slate-900 border-slate-800">
          <Title className="text-white">Events by Time of Day</Title>
          <Text className="text-slate-400">User activity by day period</Text>
          <BarChart
            className="mt-6 h-64"
            data={eventsByDayPeriod}
            index="period"
            categories={['events']}
            colors={['emerald']}
            valueFormatter={(value) => `${value} events`}
          />
        </Card>
      </div>

      {/* Event Stream */}
      <Card className="bg-slate-900 border-slate-800">
        <Title className="text-white">Real-Time Event Stream</Title>
        <Text className="text-slate-400">Latest events with context</Text>
        <div className="mt-6 space-y-3">
          {recentEvents.map((event, index) => (
            <EventRow key={index} event={event} />
          ))}
        </div>
      </Card>

      {/* Context Breakdown */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mt-8">
        <Card className="bg-slate-900 border-slate-800">
          <Title className="text-white">Device Models</Title>
          <DonutChart
            className="mt-6"
            data={[
              { name: 'iPhone 15 Pro', value: 456 },
              { name: 'iPhone 14', value: 234 },
              { name: 'iPhone 13', value: 123 },
              { name: 'Other', value: 89 },
            ]}
            category="value"
            index="name"
            colors={['emerald', 'teal', 'cyan', 'slate']}
          />
        </Card>

        <Card className="bg-slate-900 border-slate-800">
          <Title className="text-white">Network Type</Title>
          <DonutChart
            className="mt-6"
            data={[
              { name: 'WiFi', value: 789 },
              { name: 'Cellular', value: 234 },
              { name: 'Offline', value: 12 },
            ]}
            category="value"
            index="name"
            colors={['emerald', 'yellow', 'red']}
          />
        </Card>

        <Card className="bg-slate-900 border-slate-800">
          <Title className="text-white">User Segments</Title>
          <DonutChart
            className="mt-6"
            data={[
              { name: 'Free', value: 567 },
              { name: 'Premium', value: 234 },
              { name: 'Trial', value: 89 },
            ]}
            category="value"
            index="name"
            colors={['slate', 'emerald', 'yellow']}
          />
        </Card>
      </div>
    </div>
  );
}

function StatCard({
  title,
  value,
  icon,
  change,
}: {
  title: string;
  value: string;
  icon: React.ReactNode;
  change: string;
}) {
  const isPositive = change.startsWith('+');
  return (
    <Card className="bg-slate-900 border-slate-800">
      <div className="flex items-center justify-between">
        <div>
          <Text className="text-slate-400">{title}</Text>
          <Metric className="text-white">{value}</Metric>
          <Text className={isPositive ? 'text-emerald-500' : 'text-red-500'}>
            {change}
          </Text>
        </div>
        <div className="text-emerald-500">{icon}</div>
      </div>
    </Card>
  );
}

function EventRow({ event }: { event: any }) {
  return (
    <div className="flex items-center justify-between p-4 bg-slate-800 rounded-lg">
      <div className="flex items-center space-x-4">
        <div className="w-2 h-2 bg-emerald-500 rounded-full"></div>
        <div>
          <p className="text-white font-mono text-sm">{event.name}</p>
          <p className="text-slate-400 text-xs">{event.time}</p>
        </div>
      </div>
      <div className="flex items-center space-x-4">
        <span className="px-3 py-1 bg-slate-700 text-slate-300 rounded-full text-xs">
          {event.country}
        </span>
        <span className="text-slate-300">{event.count}</span>
      </div>
    </div>
  );
}
