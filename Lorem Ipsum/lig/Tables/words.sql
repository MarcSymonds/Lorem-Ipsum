CREATE TABLE [lig].[words] (
    [id]   INT           IDENTITY (1, 1) NOT NULL,
    [word] NVARCHAR (20) NULL,
    CONSTRAINT [PK_words] PRIMARY KEY CLUSTERED ([id] ASC)
);

