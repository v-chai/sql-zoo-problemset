# == Schema Information
#
# Table name: actors
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: movies
#
#  id          :integer      not null, primary key
#  title       :string
#  yr          :integer
#  score       :float
#  votes       :integer
#  director_id :integer
#
# Table name: castings
#
#  movie_id    :integer      not null, primary key
#  actor_id    :integer      not null, primary key
#  ord         :integer

require_relative './sqlzoo.rb'

def example_join
  execute(<<-SQL)
    SELECT
      *
    FROM
      movies
    JOIN
      castings ON movies.id = castings.movie_id
    JOIN
      actors ON castings.actor_id = actors.id
    WHERE
      actors.name = 'Sean Connery'
  SQL
end

def ford_films
  # List the films in which 'Harrison Ford' has appeared.
  execute(<<-SQL)
    SELECT
      title
    FROM
      movies m
    JOIN 
      castings c ON c.movie_id = m.id
    WHERE 
      c.actor_id = (
        SELECT 
          id
        FROM
          actors
        WHERE
          name LIKE 'Harrison Ford'
      )
  SQL
end

def ford_supporting_films
  # List the films where 'Harrison Ford' has appeared - but not in the star
  # role. [Note: the ord field of casting gives the position of the actor. If
  # ord=1 then this actor is in the starring role]
  execute(<<-SQL)
    SELECT
      title
    FROM
      movies m
    JOIN 
      castings c ON c.movie_id = m.id
    WHERE 
      c.actor_id = (
        SELECT 
          id
        FROM
          actors
        WHERE
          name LIKE 'Harrison Ford'
      ) AND
      c.ord > 1
  SQL
end

def films_and_stars_from_sixty_two
  # List the title and leading star of every 1962 film.
  execute(<<-SQL)
    SELECT
      m.title,
      a.name
    FROM 
      movies m
    INNER JOIN 
      castings c ON c.movie_id = m.id
    INNER JOIN
      actors a ON a.id = c.actor_id
    WHERE 
      m.yr = 1962 AND
      c.ord = 1
  SQL
end

def travoltas_busiest_years
  # Which were the busiest years for 'John Travolta'? Show the year and the
  # number of movies he made for any year in which he made at least 2 movies.
  execute(<<-SQL)
    SELECT
      m.yr,
      COUNT(m.title) AS movie_count
    FROM
      movies m
    INNER JOIN 
      castings c ON c.movie_id = m.id
    INNER JOIN
      actors a ON a.id = c.actor_id
    WHERE
      a.name LIKE 'John Travolta'
    GROUP BY
      m.yr
    HAVING
      COUNT(m.title) > 1
  SQL
end

def andrews_films_and_leads
  # List the film title and the leading actor for all of the films 'Julie
  # Andrews' played in.
  execute(<<-SQL)
    WITH andrews_movies AS (
      SELECT
        m.title,
        c.movie_id
      FROM 
        movies m
      INNER JOIN 
        castings c ON c.movie_id = m.id
      INNER JOIN
        actors a ON a.id = c.actor_id
      WHERE
        a.name LIKE 'Julie Andrews'
      )
    SELECT 
      DISTINCT(andrews_movies.title),
      a2.name
    FROM 
      andrews_movies
    LEFT JOIN 
      castings c2 ON andrews_movies.movie_id = c2.movie_id
    LEFT JOIN
      actors a2 ON a2.id = c2.actor_id
    WHERE
      c2.ord = 1
  SQL
end

def prolific_actors
  # Obtain a list in alphabetical order of actors who've had at least 15
  # starring roles.
  execute(<<-SQL)
    SELECT
      a.name
    FROM
      actors a
    LEFT JOIN 
      castings c ON c.actor_id = a.id
    WHERE
      c.ord = 1
    GROUP BY 
      a.name
    HAVING
      COUNT(c.movie_id) >= 15
    ORDER BY
      a.name
  SQL
end

def films_by_cast_size
  # List the films released in the year 1978 ordered by the number of actors
  # in the cast (descending), then by title (ascending).
  execute(<<-SQL)
    SELECT
      m.title,
      COUNT(c.actor_id)
    FROM
      movies m
    JOIN 
      castings c ON c.movie_id = m.id
    WHERE
      yr = 1978
    GROUP BY
      m.title
    ORDER BY
      COUNT(c.actor_id) DESC,
      m.title
  SQL
end

def colleagues_of_garfunkel
  # List all the people who have played alongside 'Art Garfunkel'.
  execute(<<-SQL)
    SELECT
      a.name
    FROM
      actors a
    JOIN 
      castings c ON c.actor_id = a.id
    WHERE 
      c.movie_id IN (
        SELECT
          c2.movie_id
        FROM 
          castings c2
        JOIN
          actors a2 ON c2.actor_id = a2.id
        WHERE
          a2.name = 'Art Garfunkel'
      )  AND
      a.name != 'Art Garfunkel'
  SQL
end
