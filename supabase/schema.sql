-- Create profiles table
CREATE TABLE IF NOT EXISTS public.users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT,
  name TEXT,
  skill_level INTEGER CHECK (skill_level BETWEEN 1 AND 10),
  preferred_position TEXT,
  location TEXT,
  availability TEXT[],
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create games table
CREATE TABLE IF NOT EXISTS public.games (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  location TEXT NOT NULL,
  date_time TIMESTAMPTZ NOT NULL,
  skill_level INTEGER CHECK (skill_level BETWEEN 1 AND 10),
  max_players INTEGER NOT NULL,
  current_players INTEGER DEFAULT 0,
  cost_per_player NUMERIC(10, 2) DEFAULT 0,
  organizer_id UUID REFERENCES public.users(id),
  description TEXT,
  participants UUID[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create game summaries table
CREATE TABLE IF NOT EXISTS public.game_summaries (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  game_id UUID REFERENCES public.games(id) ON DELETE CASCADE,
  summary_text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.game_summaries ENABLE ROW LEVEL SECURITY;

-- Policies for users
CREATE POLICY "Public profiles are viewable by everyone" ON public.users
  FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile" ON public.users
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Policies for games
CREATE POLICY "Games are viewable by everyone" ON public.games
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create games" ON public.games
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Game organizers can update their games" ON public.games
  FOR UPDATE USING (auth.uid() = organizer_id);

-- Policies for game summaries
CREATE POLICY "Game summaries are viewable by everyone" ON public.game_summaries
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create summaries" ON public.game_summaries
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Function to handle new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, email, name, skill_level, preferred_position, location, availability)
  VALUES (
    new.id,
    new.email,
    'New Player',
    5,
    'Midfielder',
    'San José',
    ARRAY['Saturday', 'Sunday']
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Insert some demo data for games (Optional, but good for testing)
INSERT INTO public.games (title, location, date_time, skill_level, max_players, current_players, cost_per_player, description)
VALUES 
  ('Friday Night Futbol', 'San José Central Park', NOW() + INTERVAL '1 day', 6, 14, 10, 5.00, 'Casual game for intermediate players'),
  ('Sunday Morning League', 'University Stadium', NOW() + INTERVAL '3 days', 8, 22, 18, 10.00, 'Competitive league match'),
  ('Wednesday Pickup', 'Community Center', NOW() + INTERVAL '5 days', 4, 10, 4, 2.00, 'All skill levels welcome');
