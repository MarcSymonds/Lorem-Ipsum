/*
   Generates a random piece of text based on Lorem Ipsum.
   It can generate a randmon number of paragraphs, each with a randmon number of words.
   It can also include <p> tags, or CR between paragraphs.

   To use:-

   UPDATE myTable SET myColumn = loremIpsum.lig.func_generate(1, 3, 50, 100, 1) WHERE myColumn IS NULL OR myColumn = ''

*/

CREATE FUNCTION [lig].[func_generate] (
   @minParas int = 2,            -- Minimum number of paragraphs.
   @maxParas int = 3,            -- Maximum number of paragraphs.
   @minWordsPerPara int = 70,    -- Minimum number of words per paragraph.
   @maxWordsPerPara int = 100,   -- Maximum number of words per paragraph.
   @ptags bit = 1                -- Use <p> tags. If 0, uses CR.
)
RETURNS nvarchar(max)
AS
BEGIN
   DECLARE @paras int, @para int
   DECLARE @words int, @word int
   DECLARE @text nvarchar(max)
   DECLARE @idx int
   DECLARE @wordIDLow int
   DECLARE @wordIDHigh int
   DECLARE @aWord nvarchar(30)
   DECLARE @sentence int
   DECLARE @newSentence bit, @firstSentence bit, @punctCount int
   DECLARE @rnd float

   IF @minParas = @maxParas
      SELECT @paras = @minParas
   ELSE
      SELECT @paras = lig.func_random(@minParas, @maxParas)

   SELECT @text = '', @para = 1

   SELECT @wordIDLow = MIN(id), @wordIDHigh = MAX(id) FROM lig.words

   WHILE @para <= @paras BEGIN
      IF @ptags = 1
         SELECT @text = @text + '<p>'

      IF @minWordsPerPara = @maxWordsPerPara
         SELECT @words = @minWordsPerPara
      ELSE
         SELECT @words = lig.func_random(@minWordsPerPara, @maxWordsPerPara)

      SELECT @word = @words

      SELECT @sentence = lig.func_random(5, 30), @newSentence = 1, @firstSentence = 1, @punctCount = lig.func_random(3,11)

      IF @sentence >= (@words - 3)
         SELECT @sentence = @words

      WHILE @word > 0 BEGIN
         SELECT @idx = lig.func_random(@wordIDLow, @wordIDHigh), @aWord = NULL

         SELECT @aWord = word FROM lig.words WHERE id = @idx

         IF @aWord IS NOT NULL BEGIN
            IF @newSentence = 1 BEGIN
               IF @firstSentence = 1
                  SELECT @firstSentence = 0
               ELSE
                  SELECT @text = @text + ' '

               SELECT @aWord = UPPER(SUBSTRING(@aWord, 1, 1)) + SUBSTRING(@aWord, 2, LEN(@aWord) - 1)

               SELECT @newSentence = 0
            END
            ELSE BEGIN
               SELECT @rnd = lig.func_random(0, 10)

               IF @sentence < 5 OR @punctCount > 0 OR @rnd > 0.3 
                  SELECT @text = @text + ' ', @punctCount = @punctCount - 1
               ELSE
                  SELECT @text = @text + ', ', @punctCount = lig.func_random(4, 12)
            END

            SELECT @text = @text + @aWord

            SELECT @word = @word - 1, @sentence = @sentence - 1

            IF @sentence = 0 AND @word > 3 BEGIN
               SELECT @text = @text + '.', @sentence = lig.func_random(5, 30), @newSentence = 1
            END
         END
      END

      SELECT @text = @text + '.'

      IF @ptags = 1
         SELECT @text = @text + '</p>'
      ELSE
         SELECT @text = @text + CHAR(13) + CHAR(13)

      SELECT @para = @para + 1
   END

   RETURN @text
END
