CREATE FUNCTION [lig].[func_random](@low int, @high int)
RETURNS int
AS
BEGIN
   -- View required because you can't call RAND() directly from a function.
   --
   DECLARE @result int

   SELECT @result = CAST(r.rnd * (@high - @low + 1) AS INT) + @low FROM dbo.view_random r

	RETURN @result
END
