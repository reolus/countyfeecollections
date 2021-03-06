USE [master]
GO
/****** Object:  Database [civilfeecollections]    Script Date: 4/12/2017 4:54:43 PM ******/
CREATE DATABASE [civilfeecollections]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'civilfeecollections', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\civilfeecollections.mdf' , SIZE = 49664KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 LOG ON 
( NAME = N'civilfeecollections_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\civilfeecollections_log.ldf' , SIZE = 6144KB , MAXSIZE = 2048GB , FILEGROWTH = 1%)
GO
ALTER DATABASE [civilfeecollections] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [civilfeecollections].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [civilfeecollections] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [civilfeecollections] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [civilfeecollections] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [civilfeecollections] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [civilfeecollections] SET ARITHABORT OFF 
GO
ALTER DATABASE [civilfeecollections] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [civilfeecollections] SET AUTO_SHRINK ON 
GO
ALTER DATABASE [civilfeecollections] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [civilfeecollections] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [civilfeecollections] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [civilfeecollections] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [civilfeecollections] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [civilfeecollections] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [civilfeecollections] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [civilfeecollections] SET  DISABLE_BROKER 
GO
ALTER DATABASE [civilfeecollections] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [civilfeecollections] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [civilfeecollections] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [civilfeecollections] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [civilfeecollections] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [civilfeecollections] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [civilfeecollections] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [civilfeecollections] SET RECOVERY FULL 
GO
ALTER DATABASE [civilfeecollections] SET  MULTI_USER 
GO
ALTER DATABASE [civilfeecollections] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [civilfeecollections] SET DB_CHAINING OFF 
GO
ALTER DATABASE [civilfeecollections] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [civilfeecollections] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [civilfeecollections] SET DELAYED_DURABILITY = DISABLED 
GO
USE [civilfeecollections]
GO
/****** Object:  User [POTTCOUNTY\Attorney Collections]    Script Date: 4/12/2017 4:54:43 PM ******/
CREATE USER [POTTCOUNTY\Attorney Collections] FOR LOGIN [POTTCOUNTY\Attorney Collections]
GO
/****** Object:  User [POTTCOUNTY\amccartney]    Script Date: 4/12/2017 4:54:43 PM ******/
CREATE USER [POTTCOUNTY\amccartney] FOR LOGIN [POTTCOUNTY\amccartney] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [mac_debug]    Script Date: 4/12/2017 4:54:43 PM ******/
CREATE USER [mac_debug] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [app_lard_ssrs]    Script Date: 4/12/2017 4:54:43 PM ******/
CREATE USER [app_lard_ssrs] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [POTTCOUNTY\tbutterbaugh]
GO
ALTER ROLE [db_datareader] ADD MEMBER [POTTCOUNTY\tbutterbaugh]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [POTTCOUNTY\tbutterbaugh]
GO
ALTER ROLE [db_owner] ADD MEMBER [POTTCOUNTY\Attorney Collections]
GO
ALTER ROLE [db_owner] ADD MEMBER [POTTCOUNTY\amccartney]
GO
ALTER ROLE [db_datareader] ADD MEMBER [mac_debug]
GO
ALTER ROLE [db_datareader] ADD MEMBER [app_lard_ssrs]
GO
/****** Object:  UserDefinedFunction [dbo].[GetCaseNames]    Script Date: 4/12/2017 4:54:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Seth Swanson
-- Create date: 03/15/2012
-- Description:	Creates a list of casenames based on defendantid
-- =============================================
CREATE FUNCTION [dbo].[GetCaseNames]
(
	@defendantid INT
)
RETURNS VARCHAR(500)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @casenames varchar(500)

	SELECT @casenames = Coalesce(@casenames + ', ', '') 
		+ RTRIM(LTRIM(replace(replace(replace(casename, char(10), ''), char(13), ''), char(9), '')))
	FROM PlanCase 
	WHERE defendantid = @defendantid

	RETURN @casenames

END

GO
/****** Object:  UserDefinedFunction [dbo].[GetCountyNames]    Script Date: 4/12/2017 4:54:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Seth Swanson
-- Create date: 03/15/2012
-- Description:	Creates a list of county names based on defendantid
-- =============================================
CREATE FUNCTION [dbo].[GetCountyNames]
(
	@defendantid INT
)
RETURNS VARCHAR(500)
AS
BEGIN
	-- Declare the return variable here
	DECLARE @countyNames VARCHAR(500)

	SELECT @countyNames = Coalesce(@countyNames + ', ', ' ') + county 
	FROM 
		(SELECT DISTINCT b.county FROM PlanCase AS a
			inner join IowaCounty AS b ON a.countyid = b.countyid
		where defendantid = @defendantid) AS temp

	RETURN @countyNames

END

GO
/****** Object:  Table [dbo].[Defendant]    Script Date: 4/12/2017 4:54:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Defendant](
	[defendantid] [int] IDENTITY(1,1) NOT NULL,
	[firstname] [varchar](255) NULL,
	[middlename] [varchar](255) NULL,
	[lastname] [varchar](255) NULL,
	[aka] [varchar](255) NULL,
	[ssn] [char](11) NULL,
	[birthdate] [datetime] NULL,
	[driverslicense] [varchar](255) NULL,
	[street1] [varchar](255) NULL,
	[street2] [varchar](255) NULL,
	[city] [varchar](255) NULL,
	[stateid] [int] NULL,
	[zip] [varchar](10) NULL,
	[phonehome] [varchar](30) NULL,
	[phonemobile] [varchar](30) NULL,
	[hasprobationofficer] [bit] NOT NULL,
	[probationofficer] [varchar](255) NULL,
	[barreduntil] [datetime] NULL,
	[notes] [varchar](max) NULL,
	[active] [bit] NULL,
	[updatedby] [varchar](100) NOT NULL,
	[updateddate] [datetime] NOT NULL,
	[daysinjail] [int] NULL,
	[bookingnumber] [varchar](20) NULL,
	[judgmentdate] [datetime] NULL,
	[hasjudgmentfiled] [bit] NULL,
	[judgmentfileddate] [datetime] NULL,
	[inbankruptcy] [bit] NULL,
	[bankruptcydatefiled] [datetime] NULL,
	[bankruptcyenddate] [datetime] NULL,
 CONSTRAINT [PK_Defendant] PRIMARY KEY CLUSTERED 
(
	[defendantid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DefendantEmployers]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DefendantEmployers](
	[defendantid] [int] NOT NULL,
	[employerid] [int] NOT NULL,
	[separationdate] [datetime] NULL,
	[updatedby] [varchar](100) NOT NULL,
	[updateddate] [datetime] NOT NULL,
 CONSTRAINT [PK_DefendantEmployer] PRIMARY KEY CLUSTERED 
(
	[defendantid] ASC,
	[employerid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DefendantPlans]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DefendantPlans](
	[planid] [int] IDENTITY(1,1) NOT NULL,
	[defendantid] [int] NOT NULL DEFAULT ((1)),
	[planname] [varchar](100) NOT NULL,
	[updatedby] [varchar](100) NOT NULL,
	[updateddate] [datetime] NOT NULL,
	[capp] [bit] NULL,
	[noncapp] [bit] NULL,
	[isfiled] [bit] NULL,
	[noncompliancenotice] [bit] NULL,
	[hasinsurance] [bit] NULL,
	[incontempt] [bit] NULL,
	[fileddate] [datetime] NULL,
 CONSTRAINT [Plan_PK] PRIMARY KEY CLUSTERED 
(
	[defendantid] ASC,
	[planid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY],
 CONSTRAINT [planname] UNIQUE NONCLUSTERED 
(
	[defendantid] ASC,
	[planname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Employer]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Employer](
	[employerid] [int] IDENTITY(1,1) NOT NULL,
	[employername] [varchar](255) NULL,
	[street1] [varchar](255) NULL,
	[street2] [varchar](255) NULL,
	[city] [varchar](255) NULL,
	[stateid] [int] NULL,
	[zip] [varchar](10) NULL,
	[phone] [varchar](30) NULL,
	[updatedby] [varchar](100) NOT NULL,
	[updateddate] [datetime] NOT NULL,
 CONSTRAINT [Employer_PK] PRIMARY KEY CLUSTERED 
(
	[employerid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FeePayment]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FeePayment](
	[planid] [int] NOT NULL,
	[defendantid] [int] NOT NULL,
	[feetypeid] [int] NOT NULL,
	[receiveddate] [datetime] NOT NULL,
	[amount] [decimal](10, 2) NULL,
	[updatedby] [varchar](100) NOT NULL,
	[updateddate] [datetime] NOT NULL,
 CONSTRAINT [FeePayment_PK] PRIMARY KEY CLUSTERED 
(
	[defendantid] ASC,
	[planid] ASC,
	[feetypeid] ASC,
	[receiveddate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[FeeTypes]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[FeeTypes](
	[feetypeid] [int] IDENTITY(1,1) NOT NULL,
	[feetype] [varchar](100) NOT NULL,
	[paymentorder] [int] NULL,
	[billable] [bit] NOT NULL DEFAULT ((1)),
	[updatedby] [varchar](100) NOT NULL,
	[updateddate] [datetime] NOT NULL,
 CONSTRAINT [FeeTypes_PK] PRIMARY KEY CLUSTERED 
(
	[feetypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY],
 CONSTRAINT [feetype] UNIQUE NONCLUSTERED 
(
	[feetype] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IowaCounty]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IowaCounty](
	[countyid] [int] IDENTITY(1,1) NOT NULL,
	[county] [varchar](50) NOT NULL,
	[updatedby] [varchar](100) NOT NULL DEFAULT ('1'),
	[updateddate] [datetime] NOT NULL DEFAULT (getdate()),
 CONSTRAINT [IowaCounties_PK] PRIMARY KEY CLUSTERED 
(
	[countyid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PaymentArrangementTypes]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PaymentArrangementTypes](
	[paymentarrangementtypeid] [int] IDENTITY(1,1) NOT NULL,
	[paymentarrangementtype] [varchar](100) NOT NULL,
	[updatedby] [varchar](100) NOT NULL,
	[updateddate] [datetime] NOT NULL,
 CONSTRAINT [PaymentArrangementTypes_PK] PRIMARY KEY CLUSTERED 
(
	[paymentarrangementtypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY],
 CONSTRAINT [arrangementtype] UNIQUE NONCLUSTERED 
(
	[paymentarrangementtype] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PayPeriodTypes]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PayPeriodTypes](
	[payperiodtypeid] [int] IDENTITY(1,1) NOT NULL,
	[payperiodtype] [varchar](100) NOT NULL,
	[updatedby] [varchar](100) NOT NULL,
	[updateddate] [datetime] NOT NULL,
 CONSTRAINT [PayPeriodTypes_PK] PRIMARY KEY CLUSTERED 
(
	[payperiodtypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY],
 CONSTRAINT [payperiod] UNIQUE NONCLUSTERED 
(
	[payperiodtype] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PlanCase]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PlanCase](
	[planid] [int] NOT NULL,
	[defendantid] [int] NOT NULL,
	[casename] [varchar](100) NOT NULL,
	[countyid] [int] NULL,
	[committed] [bit] NOT NULL DEFAULT ((1)),
	[commitdate] [datetime] NULL,
	[CAPP] [bit] NOT NULL DEFAULT ((0)),
	[updatedby] [varchar](100) NOT NULL,
	[updateddate] [datetime] NOT NULL,
	[commitbasedate] [datetime] NULL,
	[commitdaystill] [decimal](10, 2) NULL,
 CONSTRAINT [PK_PlanCase] PRIMARY KEY CLUSTERED 
(
	[defendantid] ASC,
	[planid] ASC,
	[casename] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PlanFee]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PlanFee](
	[planid] [int] NOT NULL,
	[defendantid] [int] NOT NULL,
	[feetypeid] [int] NOT NULL,
	[amount] [decimal](10, 2) NULL,
	[updatedby] [varchar](100) NOT NULL,
	[updateddate] [datetime] NOT NULL,
 CONSTRAINT [Fee_PK] PRIMARY KEY CLUSTERED 
(
	[defendantid] ASC,
	[planid] ASC,
	[feetypeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PlanPaymentArrangement]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PlanPaymentArrangement](
	[planid] [int] NOT NULL,
	[defendantid] [int] NOT NULL,
	[paymentarrangementid] [int] IDENTITY(1,1) NOT NULL,
	[payperiodtypeid] [int] NOT NULL,
	[paymentarrangementtypeid] [int] NOT NULL,
	[amount] [decimal](10, 2) NULL,
	[startdate] [datetime] NULL,
	[enddate] [datetime] NULL,
	[updatedby] [varchar](100) NOT NULL,
	[updateddate] [datetime] NOT NULL,
 CONSTRAINT [PaymentArrangement_PK] PRIMARY KEY CLUSTERED 
(
	[defendantid] ASC,
	[planid] ASC,
	[paymentarrangementid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RestrictedCasePrefixes]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RestrictedCasePrefixes](
	[prefixid] [int] IDENTITY(1,1) NOT NULL,
	[prefix] [varchar](10) NOT NULL,
	[updatedby] [varchar](100) NOT NULL,
	[updateddate] [datetime] NOT NULL,
 CONSTRAINT [RestrictedCasePrefixes_PK] PRIMARY KEY CLUSTERED 
(
	[prefixid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY],
 CONSTRAINT [prefix] UNIQUE NONCLUSTERED 
(
	[prefix] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[States]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[States](
	[stateid] [int] NOT NULL,
	[abbreviation] [char](2) NULL,
	[statename] [varchar](255) NULL,
 CONSTRAINT [States_PK] PRIMARY KEY CLUSTERED 
(
	[stateid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[vw_activeconnections]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_activeconnections]
AS
SELECT     spid, status, program_name, RTRIM(loginame) AS LOGINAME, hostname, cmd, { fn NOW() } AS StampedTime
FROM         MASTER.DBO.SYSPROCESSES
WHERE     (DB_NAME(dbid) = 'civilfeecollections') AND (dbid <> 0)

GO
/****** Object:  View [dbo].[vw_ClerkReport]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_ClerkReport]
AS
SELECT     TOP (100) PERCENT lastname AS [Last Name], firstname AS [First Name], middlename AS [Middle Name], dbo.GetCaseNames(defendantid) AS [Case Names], 
                      dbo.GetCountyNames(defendantid) AS [County Names]
FROM         dbo.Defendant
WHERE     (active <> 0) AND (firstname <> '') AND (lastname <> '')
ORDER BY [Last Name], [First Name]

GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [activedefendantidlastfirst]    Script Date: 4/12/2017 4:54:44 PM ******/
CREATE NONCLUSTERED INDEX [activedefendantidlastfirst] ON [dbo].[Defendant]
(
	[active] ASC,
	[lastname] ASC,
	[firstname] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [defendantidplanidreceiveddate]    Script Date: 4/12/2017 4:54:44 PM ******/
CREATE NONCLUSTERED INDEX [defendantidplanidreceiveddate] ON [dbo].[FeePayment]
(
	[defendantid] ASC,
	[planid] ASC,
	[receiveddate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [defendantidplanidcapp]    Script Date: 4/12/2017 4:54:44 PM ******/
CREATE NONCLUSTERED INDEX [defendantidplanidcapp] ON [dbo].[PlanCase]
(
	[defendantid] ASC,
	[planid] ASC,
	[countyid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
/****** Object:  Index [defendantidplanidcountyidcapp]    Script Date: 4/12/2017 4:54:44 PM ******/
CREATE NONCLUSTERED INDEX [defendantidplanidcountyidcapp] ON [dbo].[PlanCase]
(
	[defendantid] ASC,
	[planid] ASC,
	[countyid] ASC,
	[CAPP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Defendant]  WITH CHECK ADD  CONSTRAINT [States_Defendant_FK1] FOREIGN KEY([stateid])
REFERENCES [dbo].[States] ([stateid])
GO
ALTER TABLE [dbo].[Defendant] CHECK CONSTRAINT [States_Defendant_FK1]
GO
ALTER TABLE [dbo].[DefendantEmployers]  WITH CHECK ADD  CONSTRAINT [Defendant_DefendantEmployer_FK1] FOREIGN KEY([defendantid])
REFERENCES [dbo].[Defendant] ([defendantid])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DefendantEmployers] CHECK CONSTRAINT [Defendant_DefendantEmployer_FK1]
GO
ALTER TABLE [dbo].[DefendantEmployers]  WITH CHECK ADD  CONSTRAINT [Employer_DefendantEmployer_FK1] FOREIGN KEY([employerid])
REFERENCES [dbo].[Employer] ([employerid])
GO
ALTER TABLE [dbo].[DefendantEmployers] CHECK CONSTRAINT [Employer_DefendantEmployer_FK1]
GO
ALTER TABLE [dbo].[DefendantPlans]  WITH CHECK ADD  CONSTRAINT [Defendant_Plan_FK1] FOREIGN KEY([defendantid])
REFERENCES [dbo].[Defendant] ([defendantid])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[DefendantPlans] CHECK CONSTRAINT [Defendant_Plan_FK1]
GO
ALTER TABLE [dbo].[Employer]  WITH CHECK ADD  CONSTRAINT [States_Employer_FK1] FOREIGN KEY([stateid])
REFERENCES [dbo].[States] ([stateid])
GO
ALTER TABLE [dbo].[Employer] CHECK CONSTRAINT [States_Employer_FK1]
GO
ALTER TABLE [dbo].[FeePayment]  WITH CHECK ADD  CONSTRAINT [FeeTypes_FeePayment_FK1] FOREIGN KEY([feetypeid])
REFERENCES [dbo].[FeeTypes] ([feetypeid])
GO
ALTER TABLE [dbo].[FeePayment] CHECK CONSTRAINT [FeeTypes_FeePayment_FK1]
GO
ALTER TABLE [dbo].[FeePayment]  WITH CHECK ADD  CONSTRAINT [PlanFee_FeePayment_FK1] FOREIGN KEY([defendantid], [planid], [feetypeid])
REFERENCES [dbo].[PlanFee] ([defendantid], [planid], [feetypeid])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[FeePayment] CHECK CONSTRAINT [PlanFee_FeePayment_FK1]
GO
ALTER TABLE [dbo].[PlanCase]  WITH CHECK ADD  CONSTRAINT [DefendantPlans_PlanCase_FK1] FOREIGN KEY([defendantid], [planid])
REFERENCES [dbo].[DefendantPlans] ([defendantid], [planid])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PlanCase] CHECK CONSTRAINT [DefendantPlans_PlanCase_FK1]
GO
ALTER TABLE [dbo].[PlanCase]  WITH CHECK ADD  CONSTRAINT [IowaCounty_PlanCase_FK1] FOREIGN KEY([countyid])
REFERENCES [dbo].[IowaCounty] ([countyid])
GO
ALTER TABLE [dbo].[PlanCase] CHECK CONSTRAINT [IowaCounty_PlanCase_FK1]
GO
ALTER TABLE [dbo].[PlanFee]  WITH CHECK ADD  CONSTRAINT [FeeTypes_PlanFee_FK1] FOREIGN KEY([feetypeid])
REFERENCES [dbo].[FeeTypes] ([feetypeid])
GO
ALTER TABLE [dbo].[PlanFee] CHECK CONSTRAINT [FeeTypes_PlanFee_FK1]
GO
ALTER TABLE [dbo].[PlanFee]  WITH CHECK ADD  CONSTRAINT [Plan_Fee_FK1] FOREIGN KEY([defendantid], [planid])
REFERENCES [dbo].[DefendantPlans] ([defendantid], [planid])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PlanFee] CHECK CONSTRAINT [Plan_Fee_FK1]
GO
ALTER TABLE [dbo].[PlanPaymentArrangement]  WITH CHECK ADD  CONSTRAINT [DefendantPlans_PlanPaymentArrangement_FK1] FOREIGN KEY([defendantid], [planid])
REFERENCES [dbo].[DefendantPlans] ([defendantid], [planid])
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[PlanPaymentArrangement] CHECK CONSTRAINT [DefendantPlans_PlanPaymentArrangement_FK1]
GO
ALTER TABLE [dbo].[PlanPaymentArrangement]  WITH CHECK ADD  CONSTRAINT [PaymentArrangementTypes_PlanPaymentArrangement_FK1] FOREIGN KEY([paymentarrangementtypeid])
REFERENCES [dbo].[PaymentArrangementTypes] ([paymentarrangementtypeid])
GO
ALTER TABLE [dbo].[PlanPaymentArrangement] CHECK CONSTRAINT [PaymentArrangementTypes_PlanPaymentArrangement_FK1]
GO
ALTER TABLE [dbo].[PlanPaymentArrangement]  WITH CHECK ADD  CONSTRAINT [PayPeriodTypes_PaymentArrangement_FK1] FOREIGN KEY([payperiodtypeid])
REFERENCES [dbo].[PayPeriodTypes] ([payperiodtypeid])
GO
ALTER TABLE [dbo].[PlanPaymentArrangement] CHECK CONSTRAINT [PayPeriodTypes_PaymentArrangement_FK1]
GO
/****** Object:  StoredProcedure [dbo].[Print_DelinquentNotices]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Programmer (modified from original)
-- Create date: 9/22/2010
-- Description:	Procedure for finding list of delinquent defendants and automatically printing notices.
-- Updated:     Contractor (09/19/2011) removed 1st and 2nd deliquency references.  
--				Updated noncompliance reference from Defendant to DefendantPlans.
-- Updated:     Contractor (10/07/2012) renamed from sp_delinquent_notices to Print_DelinquentNotices.
-- =============================================
CREATE PROCEDURE [dbo].[Print_DelinquentNotices] 
(
	@input_DateTime DateTime
)
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

	THROW 990100, 'SP [Print_DelinquentNotices]	NO LONGER TO BE USED.  THE SYSTEM NOW ALWAYS USES [Print_DelinquentNotices]ExcludesBankruptcies. THIS SHOULD NOT BE RUN.  THE SP BODY IS UNCHANGED, ONLY THIS THROW STATEMENT IS ADDED TO PREVENT ACCIDENTAL USAGE.', 10;
	--remove this stored proc when comfortable the replacement [Print_DelinquentNotices]ExcludesBankruptcies is working correctly.

  SELECT lastname, firstname, street1, street2, city, stateAbbr, zip, [#ofdaysbehind]
    FROM
         (
         SELECT DISTINCT b.defendantid, b.lastname, b.firstname, b.street1, b.street2, b.city, b.stateAbbr, b.zip, b.planid, b.planname, b.[Last Payment Date], b.[Last Payment Amount], b.[current payment arrangement start date],
                b.[numberofpaymentsmadesincestartdate], payperiodtype, PlanPaymentArrangement.amount, b.Noncompliance,
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime )
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN DATEDIFF( WEEK, b.[current payment arrangement start date], @input_DateTime )
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2
                    ELSE 0
				END AS #ofpayperiodssincestartdate,
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime )
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN PlanPaymentArrangement.amount * DATEDIFF( WEEK, b.[current payment arrangement start date], @input_DateTime )
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2
                    ELSE 0
				END AS [amountusershouldhavepaidbynow],
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( WEEK, b.[current payment arrangement start date], @input_DateTime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
                    ELSE 0
				END AS #ofpaymentsuserowes,
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN (DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount)
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN (DATEDIFF( WEEK, b.[current payment arrangement start date], @input_DateTime ) - ((PlanPaymentArrangement.amount * DATEDIFF( WEEK, b.[current payment arrangement start date], @input_DateTime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount )
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN ((DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount )
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN ((DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount )
                    ELSE 0
				END AS #ofpayperiodsuserhasmade,
				DATEDIFF( DAY ,[Last Payment Date], @input_datetime) AS [#ofdaysbehind]
           FROM   
                (
                SELECT a.defendantid, a.lastname, a.firstname, a.planid, a.planname, a.[Last Payment Date], a.[Last Payment Amount], MAX(a.startdate) AS [current payment arrangement start date],
                       DATEDIFF( DAY, ISNULL( [Last Payment Date], MAX(a.startdate) ), @input_DateTime) AS [dayssincelastpayment], 
	                   (SELECT COUNT(receiveddate) FROM FeePayment WHERE a.defendantid = FeePayment.defendantid AND a.planid = FeePayment.planid AND receiveddate > MAX(a.startdate)
					   ) AS [numberofpaymentsmadesincestartdate],
					   (SELECT COUNT(receiveddate) FROM FeePayment WHERE a.defendantid = FeePayment.defendantid AND a.planid = FeePayment.planid AND receiveddate > MAX(a.startdate)
					   ) AS [numberofpayperiodsincepaymentarrangementstartdate] ,
					   (SELECT ISNULL(SUM(amount),0) FROM FeePayment WHERE a.defendantid = FeePayment.defendantid AND a.planid = FeePayment.planid AND receiveddate > MAX(a.startdate)
					   ) AS [totalamountuserhaspaidsincestartdate], a.street1, a.street2, a.city, a.stateAbbr, a.zip, a.Noncompliance
                  FROM
	                   (
                       SELECT Defendant.defendantid, lastname, firstname, DefendantPlans.planid, planname, LastPayment.receiveddate AS [Last Payment Date], SUM(FeePayment.amount) AS [Last Payment Amount],
                              PlanPaymentArrangement.startdate, street1, street2, city, States.abbreviation as stateAbbr, zip, DefendantPlans.noncompliancenotice AS Noncompliance
                         FROM Defendant
				   INNER JOIN States ON Defendant.stateid = States.stateid
              LEFT OUTER JOIN DefendantPlans ON Defendant.defendantid = DefendantPlans.defendantid
              LEFT OUTER JOIN (
	                          SELECT defendantid, planid, MAX(receiveddate) AS receiveddate
                                FROM FeePayment
	                        GROUP BY defendantid, planid
                              ) AS LastPayment ON DefendantPlans.defendantid = LastPayment.defendantid AND DefendantPlans.planid = LastPayment.planid  
              LEFT OUTER JOIN FeePayment ON LastPayment.defendantid = FeePayment.defendantid AND FeePayment.planid = LastPayment.planid AND FeePayment.receiveddate = LastPayment.receiveddate
                   INNER JOIN PlanPaymentArrangement ON DefendantPlans.defendantid = PlanPaymentArrangement.defendantid AND DefendantPlans.planid = PlanPaymentArrangement.planid
                        WHERE Defendant.active = 1 AND DefendantPlans.planid IS NOT NULL AND NOT( Defendant.street1 = '' AND Defendant.street2 = '')
				              AND NOT EXISTS (
					                         SELECT defendantid, planid
						                       FROM (
					                                SELECT defendantid, planid, SUM(amount) AS total
													  FROM PlanFee 
											      GROUP BY defendantid, planid
												     UNION
												    SELECT defendantid, planid, -SUM( amount  ) AS total
												      FROM FeePayment
												  GROUP BY defendantid, planid
											        ) AS Transactions
										   	  WHERE Transactions.defendantid = DefendantPlans.defendantid AND Transactions.planid = DefendantPlans.planid 
										   GROUP BY defendantid, planid
										     HAVING SUM(total) = 0
										     )
                     GROUP BY Defendant.defendantid, lastname, firstname, DefendantPlans.planid, planname, LastPayment.receiveddate, PlanPaymentArrangement.startdate, PlanPaymentArrangement.amount, street1, street2, city, States.abbreviation, zip, DefendantPlans.noncompliancenotice
				       ) AS a    
              GROUP BY a.defendantid, a.lastname, a.firstname, a.planid, a.planname, a.[Last Payment Date], a.[Last Payment Amount], a.street1, a.street2, a.city, a.stateAbbr, a.zip, Noncompliance
		        ) AS b
     INNER JOIN PlanPaymentArrangement ON b.defendantid = PlanPaymentArrangement.defendantid AND b.planid = PlanPaymentArrangement.planid AND b.[current payment arrangement start date] = PlanPaymentArrangement.startdate
     INNER JOIN PayPeriodTypes ON PlanPaymentArrangement.payperiodtypeid = PayPeriodTypes.payperiodtypeid )
         AS z  where [#ofdaysbehind] between 31 and 181 
ORDER BY lastname, firstname, planname
END


GO
/****** Object:  StoredProcedure [dbo].[Print_DelinquentNoticesExcludeBankruptcy]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Programmer (modified from original)
-- Create date: 9/22/2010
-- Description:	Procedure for finding list of delinquent defendants and automatically printing notices.
-- Updated:     Contractor (09/19/2011) removed 1st and 2nd deliquency references.  
--				Updated noncompliance reference from Defendant to DefendantPlans.
-- Updated:     Contractor (10/07/2012) renamed from sp_delinquent_notices to Print_DelinquentNotices.
-- =============================================
CREATE PROCEDURE [dbo].[Print_DelinquentNoticesExcludeBankruptcy] 
(
	@input_DateTime DateTime
)
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE Defendant SET inbankruptcy=0 WHERE inbankruptcy=1 and bankruptcyenddate<CURRENT_TIMESTAMP;



  SELECT lastname, firstname, street1, street2, city, stateAbbr, zip, [#ofdaysbehind]
    FROM
         (
         SELECT DISTINCT b.defendantid, b.lastname, b.firstname, b.street1, b.street2, b.city, b.stateAbbr, b.zip, b.planid, b.planname, b.[Last Payment Date], b.[Last Payment Amount], b.[current payment arrangement start date],
                b.[numberofpaymentsmadesincestartdate], payperiodtype, PlanPaymentArrangement.amount, b.Noncompliance,
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime )
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN DATEDIFF( WEEK, b.[current payment arrangement start date], @input_DateTime )
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2
                    ELSE 0
				END AS #ofpayperiodssincestartdate,
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime )
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN PlanPaymentArrangement.amount * DATEDIFF( WEEK, b.[current payment arrangement start date], @input_DateTime )
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2
                    ELSE 0
				END AS [amountusershouldhavepaidbynow],
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( WEEK, b.[current payment arrangement start date], @input_DateTime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
                    ELSE 0
				END AS #ofpaymentsuserowes,
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN (DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount)
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN (DATEDIFF( WEEK, b.[current payment arrangement start date], @input_DateTime ) - ((PlanPaymentArrangement.amount * DATEDIFF( WEEK, b.[current payment arrangement start date], @input_DateTime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount )
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN ((DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount )
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN ((DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_DateTime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount )
                    ELSE 0
				END AS #ofpayperiodsuserhasmade,
				DATEDIFF( DAY ,[Last Payment Date], @input_datetime) AS [#ofdaysbehind]
           FROM   
                (
                SELECT a.defendantid, a.lastname, a.firstname, a.planid, a.planname, a.[Last Payment Date], a.[Last Payment Amount], MAX(a.startdate) AS [current payment arrangement start date],
                       DATEDIFF( DAY, ISNULL( [Last Payment Date], MAX(a.startdate) ), @input_DateTime) AS [dayssincelastpayment], 
	                   (SELECT COUNT(receiveddate) FROM FeePayment WHERE a.defendantid = FeePayment.defendantid AND a.planid = FeePayment.planid AND receiveddate > MAX(a.startdate)
					   ) AS [numberofpaymentsmadesincestartdate],
					   (SELECT COUNT(receiveddate) FROM FeePayment WHERE a.defendantid = FeePayment.defendantid AND a.planid = FeePayment.planid AND receiveddate > MAX(a.startdate)
					   ) AS [numberofpayperiodsincepaymentarrangementstartdate] ,
					   (SELECT ISNULL(SUM(amount),0) FROM FeePayment WHERE a.defendantid = FeePayment.defendantid AND a.planid = FeePayment.planid AND receiveddate > MAX(a.startdate)
					   ) AS [totalamountuserhaspaidsincestartdate], a.street1, a.street2, a.city, a.stateAbbr, a.zip, a.Noncompliance
                  FROM
	                   (
                       SELECT Defendant.defendantid, lastname, firstname, DefendantPlans.planid, planname, LastPayment.receiveddate AS [Last Payment Date], SUM(FeePayment.amount) AS [Last Payment Amount],
                              PlanPaymentArrangement.startdate, street1, street2, city, States.abbreviation as stateAbbr, zip, DefendantPlans.noncompliancenotice AS Noncompliance
                         FROM Defendant
				   INNER JOIN States ON Defendant.stateid = States.stateid
              LEFT OUTER JOIN DefendantPlans ON Defendant.defendantid = DefendantPlans.defendantid
              LEFT OUTER JOIN (
	                          SELECT defendantid, planid, MAX(receiveddate) AS receiveddate
                                FROM FeePayment
	                        GROUP BY defendantid, planid
                              ) AS LastPayment ON DefendantPlans.defendantid = LastPayment.defendantid AND DefendantPlans.planid = LastPayment.planid  
              LEFT OUTER JOIN FeePayment ON LastPayment.defendantid = FeePayment.defendantid AND FeePayment.planid = LastPayment.planid AND FeePayment.receiveddate = LastPayment.receiveddate
                   INNER JOIN PlanPaymentArrangement ON DefendantPlans.defendantid = PlanPaymentArrangement.defendantid AND DefendantPlans.planid = PlanPaymentArrangement.planid
                        WHERE Defendant.active = 1 AND DefendantPlans.planid IS NOT NULL AND NOT( Defendant.street1 = '' AND Defendant.street2 = '')
				              AND NOT EXISTS (
					                         SELECT defendantid, planid
						                       FROM (
					                                SELECT defendantid, planid, SUM(amount) AS total
													  FROM PlanFee 
											      GROUP BY defendantid, planid
												     UNION
												    SELECT defendantid, planid, -SUM( amount  ) AS total
												      FROM FeePayment
												  GROUP BY defendantid, planid
											        ) AS Transactions
										   	  WHERE Transactions.defendantid = DefendantPlans.defendantid AND Transactions.planid = DefendantPlans.planid 
										   GROUP BY defendantid, planid
										     HAVING SUM(total) = 0
										     )
							 AND (inbankruptcy=0 OR bankruptcyenddate<CURRENT_TIMESTAMP)
                     GROUP BY Defendant.defendantid, lastname, firstname, DefendantPlans.planid, planname, LastPayment.receiveddate, PlanPaymentArrangement.startdate, PlanPaymentArrangement.amount, street1, street2, city, States.abbreviation, zip, DefendantPlans.noncompliancenotice
				       ) AS a    
              GROUP BY a.defendantid, a.lastname, a.firstname, a.planid, a.planname, a.[Last Payment Date], a.[Last Payment Amount], a.street1, a.street2, a.city, a.stateAbbr, a.zip, Noncompliance
		        ) AS b
     INNER JOIN PlanPaymentArrangement ON b.defendantid = PlanPaymentArrangement.defendantid AND b.planid = PlanPaymentArrangement.planid AND b.[current payment arrangement start date] = PlanPaymentArrangement.startdate
     INNER JOIN PayPeriodTypes ON PlanPaymentArrangement.payperiodtypeid = PayPeriodTypes.payperiodtypeid )
         AS z  where [#ofdaysbehind] between 46 and 181 
ORDER BY lastname, firstname, planname
END


GO
/****** Object:  StoredProcedure [dbo].[Report_AccountStatus]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*******************************************************************************************************************
Author:  Contractor
Date:    10/07/2012
Name:    Report_AccountStatus
Version: 1.3.0.0

Module Purpose:
	This stored procedure will retreive the current payment arrangement status for a defendant.


Module Description:
	This stored procedure will retreive a defendan't payment arrangement start date, amount due each period, 
	the total amount the user has paid since the payment arrangement start date, and the number of pay periods 
    since the payment arrangement start date.

    The stored procedure first retreives all active defendant information which have account balances or a
    current payment plan (Exclusive OR).  It then calculates the amount the defendant should have paid by now:

		amount due each peiod * number of payperiods since the payment arrangement start date

	If the total amount the user has paid since the payment arrangement start date is greater than
    or equal to the amount the defendant should have paid by now, the user is in a 'Current' status.  Otherwise, 
    the user owes money and is late on making a payment.

    Next, the stored procedure determines how many payments each user is behind:
    
		( amount defendant should have paid by now - total amount user has paid since startdate ) 
			/
			amount due each period
 
    indiciates how many pay periods the defendant needs to pay in order to be current.  (If it's negative, the 
    defendant is ahead of planned payments by the number of pay periods.)  If it is positive, the stored
    procedure determines the number of payments the user has technically covered with the total amount paid 
    during the current payment arrangement period:

		number of pay periods since start date - number of pay periods the defendant needs in order to be current

    To determine the last payment date the user was considered current:

        payment arrangement start date + ( number of payperiods user has made * pay period length )

	Finally the stored procedure subtracts the last payment date the user was considered current from the date passed 
    in as a parameter into the stored procedure.  The result is the number of days the defendant is behind in 
    payments.

    The stored procedure also returns the last name, first name, plan name, last payment date, last payment amount, 
    the number of days the defendant is deliquent and the current status of the payment arrangement:
    
		> 90 days
        > 60 days    
        > 30 days
        Current


    The main issue that caused me problems was the ability for a defendant to make more than one payment between
    pay periods.  Plus, if the defendant paid more than their elected payment amount things were more complicated.
    The stored procedure gives the defendant the benefit of the doubt if they have made more payments
    than what is currently owed.  This keeps all of the reports and data items, such as the payment
    arrangement end date in synch.

    It is ugly and unfactored.  Good luck.    

	
Calling Arguments:

	Name            I/O Description
	--------------- --- ----------------------------------------------------------------------------------------------
	@input_DateTime	 I  The date to determine account deliquency from.

Change History:

	Author          Date       Description
	--------------- ---------- ---------------------------------------------------------------------------------------
	Contractor      04/25/2009 Original Code
    Contractor      06/02/2009 Bi-Weekly # pay periods was calculated incorrectly.  Fixed so that all computed 
                               columns calculate correctly.
    Contractor      09/19/2011 removed 1st and 2nd deliquency references.  Updated noncompliance reference from
                               Defendant to DefendantPlans.
    Contractor      10/02/2012 added plan filed column and middle name
    Contractor      10/07/2012 renamed from sp_account_status_data2 to Report_AccountStatus
*******************************************************************************************************************/

CREATE PROCEDURE [dbo].[Report_AccountStatus] 
(
	@input_DateTime DateTime
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;
	
	THROW 990100, 'SP Report_AccountStatus	NO LONGER TO BE USED.  THE SYSTEM NOW ALWAYS USES Report_AccountStatusLenientBilling THIS SHOULD NOT BE RUN.  THE SP BODY IS UNCHANGED, ONLY THIS THROW STATEMENT IS ADDED TO PREVENT ACCIDENTAL USAGE.', 10;

  SELECT lastname, firstname + ' ' + middlename as firstname, planname, isfiled,  [Last Payment Date], [Last Payment Amount],  [#ofdaysbehind],
	     CASE 
			WHEN [#ofdaysbehind] > 90 THEN '90 days'
			WHEN [#ofdaysbehind] > 60 THEN '60 days'
			WHEN [#ofdaysbehind] > 30 THEN '30 days'
			ELSE 'Current' 
		 END as deliquentstatus, Noncompliance
    FROM
         (
         SELECT DISTINCT b.defendantid, b.lastname, b.firstname, b.middlename, b.planid, b.planname, b.isfiled, b.[Last Payment Date], b.[Last Payment Amount], b.[current payment arrangement start date],
                b.[numberofpaymentsmadesincestartdate], payperiodtype, PlanPaymentArrangement.amount, b.Noncompliance,
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime )
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN DATEDIFF( WEEK, b.[current payment arrangement start date], @input_datetime )
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2
                    ELSE 0
				END AS #ofpayperiodssincestartdate,
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime )
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN PlanPaymentArrangement.amount * DATEDIFF( WEEK, b.[current payment arrangement start date], @input_datetime )
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2
                    ELSE 0
				END AS [amountusershouldhavepaidbynow],
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( WEEK, b.[current payment arrangement start date], @input_datetime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
                    ELSE 0
				END AS #ofpaymentsuserowes,
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN (DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount)
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN (DATEDIFF( WEEK, b.[current payment arrangement start date], @input_datetime ) - ((PlanPaymentArrangement.amount * DATEDIFF( WEEK, b.[current payment arrangement start date], @input_datetime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount )
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN ((DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount )
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN ((DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount )
                    ELSE 0
				END AS #ofpayperiodsuserhasmade,
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN DATEDIFF( DAY ,DATEADD( MONTH, (DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount), b.[current payment arrangement start date] ), @input_datetime)
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN DATEDIFF( DAY ,DATEADD( WEEK, (DATEDIFF( WEEK, b.[current payment arrangement start date], @input_datetime ) - ((PlanPaymentArrangement.amount * DATEDIFF( WEEK, b.[current payment arrangement start date], @input_datetime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount ), b.[current payment arrangement start date] ), @input_datetime)
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN DATEDIFF( DAY ,DATEADD( MONTH, ((DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount ) * 2, b.[current payment arrangement start date] ), @input_datetime)
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN DATEDIFF( DAY ,DATEADD( WEEK, ((DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount ) * 2, b.[current payment arrangement start date] ), @input_datetime)
                    ELSE 0
				END AS [#ofdaysbehind]
           FROM   
                (
                SELECT a.defendantid, a.lastname, a.firstname, a.middlename, a.planid, a.planname, a.isfiled, a.[Last Payment Date], a.[Last Payment Amount], MAX(a.startdate) AS [current payment arrangement start date],
                       DATEDIFF( DAY, ISNULL( [Last Payment Date], MAX(a.startdate) ), @input_datetime) AS [dayssincelastpayment], 
	                   (SELECT COUNT(receiveddate) FROM FeePayment WHERE a.defendantid = FeePayment.defendantid AND a.planid = FeePayment.planid AND receiveddate > MAX(a.startdate)
					   ) AS [numberofpaymentsmadesincestartdate],
					   (SELECT COUNT(receiveddate) FROM FeePayment WHERE a.defendantid = FeePayment.defendantid AND a.planid = FeePayment.planid AND receiveddate > MAX(a.startdate)
					   ) AS [numberofpayperiodsincepaymentarrangementstartdate] ,
					   (SELECT ISNULL(SUM(amount),0) FROM FeePayment WHERE a.defendantid = FeePayment.defendantid AND a.planid = FeePayment.planid AND receiveddate > MAX(a.startdate)
					   ) AS [totalamountuserhaspaidsincestartdate], a.street1, a.street2, a.Noncompliance
                  FROM
	                   (
                       SELECT Defendant.defendantid, lastname, firstname, middlename, DefendantPlans.planid, planname, isfiled, LastPayment.receiveddate AS [Last Payment Date], SUM(FeePayment.amount) AS [Last Payment Amount],
                              PlanPaymentArrangement.startdate, street1, street2, DefendantPlans.noncompliancenotice AS Noncompliance
                         FROM Defendant
              LEFT OUTER JOIN DefendantPlans ON Defendant.defendantid = DefendantPlans.defendantid
              LEFT OUTER JOIN (
	                          SELECT defendantid, planid, MAX(receiveddate) AS receiveddate
                                FROM FeePayment
	                        GROUP BY defendantid, planid
                              ) AS LastPayment ON DefendantPlans.defendantid = LastPayment.defendantid AND DefendantPlans.planid = LastPayment.planid  
              LEFT OUTER JOIN FeePayment ON LastPayment.defendantid = FeePayment.defendantid AND FeePayment.planid = LastPayment.planid AND FeePayment.receiveddate = LastPayment.receiveddate
                   INNER JOIN PlanPaymentArrangement ON DefendantPlans.defendantid = PlanPaymentArrangement.defendantid AND DefendantPlans.planid = PlanPaymentArrangement.planid
                        WHERE Defendant.active = 1 AND DefendantPlans.planid IS NOT NULL AND NOT( Defendant.street1 = '' AND Defendant.street2 = '')
				              AND NOT EXISTS (
					                         SELECT defendantid, planid
						                       FROM (
					                                SELECT defendantid, planid, SUM(amount) AS total
													  FROM PlanFee 
											      GROUP BY defendantid, planid
												     UNION
												    SELECT defendantid, planid, -SUM( amount  ) AS total
												      FROM FeePayment
												  GROUP BY defendantid, planid
											        ) AS Transactions
										   	  WHERE Transactions.defendantid = DefendantPlans.defendantid AND Transactions.planid = DefendantPlans.planid 
										   GROUP BY defendantid, planid
										     HAVING SUM(total) = 0
										     )
                     GROUP BY Defendant.defendantid, lastname, firstname, middlename, DefendantPlans.planid, planname, isfiled, LastPayment.receiveddate, PlanPaymentArrangement.startdate, PlanPaymentArrangement.amount, street1, street2, DefendantPlans.noncompliancenotice
				       ) AS a    
              GROUP BY a.defendantid, a.lastname, a.firstname, a.middlename, a.planid, a.planname, a.isfiled, a.[Last Payment Date], a.[Last Payment Amount], a.street1, a.street2, Noncompliance
		        ) AS b
     INNER JOIN PlanPaymentArrangement ON b.defendantid = PlanPaymentArrangement.defendantid AND b.planid = PlanPaymentArrangement.planid AND b.[current payment arrangement start date] = PlanPaymentArrangement.startdate
     INNER JOIN PayPeriodTypes ON PlanPaymentArrangement.payperiodtypeid = PayPeriodTypes.payperiodtypeid )
         AS z -- where [Last Payment Amount] is not null --and DateDiff(Day, [Last Payment Date], getDate()) > 30
ORDER BY lastname, firstname, planname


END


GO
/****** Object:  StoredProcedure [dbo].[Report_AccountStatusLenientBilling]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************************************
Author:  Scott Owen
Date:    10/07/2012
Name:    Report_AccountStatusLenientBilling
Version: 1.3.0.0

Module Purpose:
	This stored procedure will retreive the current payment arrangement status for a defendant.


Module Description:
	This stored procedure will retreive a defendan't payment arrangement start date, amount due each period, 
	the total amount the user has paid since the payment arrangement start date, and the number of pay periods 
    since the payment arrangement start date.

    The stored procedure first retreives all active defendant information which have account balances or a
    current payment plan (Exclusive OR).  It then calculates the amount the defendant should have paid by now:

		amount due each peiod * number of payperiods since the payment arrangement start date

	If the total amount the user has paid since the payment arrangement start date is greater than
    or equal to the amount the defendant should have paid by now, the user is in a 'Current' status.  Otherwise, 
    the user owes money and is late on making a payment.

    Next, the stored procedure determines how many payments each user is behind:
    
		( amount defendant should have paid by now - total amount user has paid since startdate ) 
			/
			amount due each period
 
    indiciates how many pay periods the defendant needs to pay in order to be current.  (If it's negative, the 
    defendant is ahead of planned payments by the number of pay periods.)  If it is positive, the stored
    procedure determines the number of payments the user has technically covered with the total amount paid 
    during the current payment arrangement period:

		number of pay periods since start date - number of pay periods the defendant needs in order to be current

    To determine the last payment date the user was considered current:

        payment arrangement start date + ( number of payperiods user has made * pay period length )

	Finally the stored procedure subtracts the last payment date the user was considered current from the date passed 
    in as a parameter into the stored procedure.  The result is the number of days the defendant is behind in 
    payments.

    The stored procedure also returns the last name, first name, plan name, last payment date, last payment amount, 
    the number of days the defendant is deliquent and the current status of the payment arrangement:
    
		> 90 days
        > 60 days    
        > 30 days
        Current


    The main issue that caused me problems was the ability for a defendant to make more than one payment between
    pay periods.  Plus, if the defendant paid more than their elected payment amount things were more complicated.
    The stored procedure gives the defendant the benefit of the doubt if they have made more payments
    than what is currently owed.  This keeps all of the reports and data items, such as the payment
    arrangement end date in synch.

    It is ugly and unfactored.  Good luck.    

	
Calling Arguments:

	Name            I/O Description
	--------------- --- ----------------------------------------------------------------------------------------------
	@input_DateTime	 I  The date to determine account deliquency from.

Change History:

	Author          Date       Description
	--------------- ---------- ---------------------------------------------------------------------------------------
	Scott Owen      04/25/2009 Original Code
    Scott Owen      06/02/2009 Bi-Weekly # pay periods was calculated incorrectly.  Fixed so that all computed 
                               columns calculate correctly.
	Seth Swanson    06/22/2009 Copy created of the original to provide for lenient billing.  This was quicker and easier.
    Scott Owen      09/21/2011 removed 1st and 2nd deliquency references.  Updated noncompliance reference from
                               Defendant to DefendantPlans.
    Scott Owen      10/02/2012 added plan filed column and middle name
    Scott Owen      10/07/2012 renamed from sp_account_status_data2 to Report_AccountStatusLenientBilling
*******************************************************************************************************************/

CREATE PROCEDURE [dbo].[Report_AccountStatusLenientBilling] 
(
	@input_DateTime DateTime
)
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;


  SELECT lastname, firstname + ' ' + middlename as firstname, planname, isfiled, [Last Payment Date], [Last Payment Amount],  [#ofdaysbehind],
	     CASE
			WHEN [Last Payment Date] IS NULL THEN
				CASE 
					WHEN [#ofdayssincestart] > 90 THEN '90 days'
					WHEN [#ofdayssincestart] > 60 THEN '60 days'
					WHEN [#ofdayssincestart] > 30 THEN '30 days'
					ELSE 'Current'
				END
			WHEN [#ofdaysbehind] > 0 THEN
				CASE 
					WHEN [#ofdaysbehind] > 90 THEN '90 days'
					WHEN [#ofdaysbehind] > 60 THEN '60 days'
					WHEN [#ofdaysbehind] > 30 THEN '30 days'
					ELSE 'Current' 
				END
		 END as deliquentstatus, Noncompliance
    FROM
         (
         SELECT DISTINCT b.defendantid, b.lastname, b.firstname, b.middlename, b.planid, b.planname, b.isfiled, b.[Last Payment Date], b.[Last Payment Amount], b.[current payment arrangement start date],
                b.[numberofpaymentsmadesincestartdate], payperiodtype, PlanPaymentArrangement.amount, b.Noncompliance,
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime )
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN DATEDIFF( WEEK, b.[current payment arrangement start date], @input_datetime )
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2
                    ELSE 0
				END AS #ofpayperiodssincestartdate,
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime )
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN PlanPaymentArrangement.amount * DATEDIFF( WEEK, b.[current payment arrangement start date], @input_datetime )
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2
                    ELSE 0
				END AS [amountusershouldhavepaidbynow],
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( WEEK, b.[current payment arrangement start date], @input_datetime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount
                    ELSE 0
				END AS #ofpaymentsuserowes,
				CASE 
					WHEN UPPER(payperiodtype) = 'MONTHLY' THEN (DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount)
					WHEN UPPER(payperiodtype) = 'WEEKLY' THEN (DATEDIFF( WEEK, b.[current payment arrangement start date], @input_datetime ) - ((PlanPaymentArrangement.amount * DATEDIFF( WEEK, b.[current payment arrangement start date], @input_datetime )) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount )
					WHEN UPPER(payperiodtype) = 'BI-MONTHLY' THEN ((DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount )
					WHEN UPPER(payperiodtype) = 'BI-WEEKLY' THEN ((DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - ((PlanPaymentArrangement.amount * DATEDIFF( MONTH, b.[current payment arrangement start date], @input_datetime ) * 2) - b.[totalamountuserhaspaidsincestartdate] )/PlanPaymentArrangement.amount )
                    ELSE 0
				END AS #ofpayperiodsuserhasmade,
				DATEDIFF( DAY ,[Last Payment Date], @input_datetime) AS [#ofdaysbehind],
				DATEDIFF( DAY ,b.[current payment arrangement start date], @input_datetime) AS [#ofdayssincestart]
           FROM   
                (
                SELECT a.defendantid, a.lastname, a.firstname, a.middlename, a.planid, a.planname, a.isfiled, a.[Last Payment Date], a.[Last Payment Amount], MAX(a.startdate) AS [current payment arrangement start date],
                       DATEDIFF( DAY, ISNULL( [Last Payment Date], MAX(a.startdate) ), @input_datetime) AS [dayssincelastpayment], 
	                   (SELECT COUNT(receiveddate) FROM FeePayment WHERE a.defendantid = FeePayment.defendantid AND a.planid = FeePayment.planid AND receiveddate > MAX(a.startdate)
					   ) AS [numberofpaymentsmadesincestartdate],
					   (SELECT COUNT(receiveddate) FROM FeePayment WHERE a.defendantid = FeePayment.defendantid AND a.planid = FeePayment.planid AND receiveddate > MAX(a.startdate)
					   ) AS [numberofpayperiodsincepaymentarrangementstartdate] ,
					   (SELECT ISNULL(SUM(amount),0) FROM FeePayment WHERE a.defendantid = FeePayment.defendantid AND a.planid = FeePayment.planid AND receiveddate > MAX(a.startdate)
					   ) AS [totalamountuserhaspaidsincestartdate], a.street1, a.street2, a.Noncompliance
                  FROM
	                   (
                       SELECT Defendant.defendantid, lastname, firstname, middlename, DefendantPlans.planid, planname, isfiled, LastPayment.receiveddate AS [Last Payment Date], SUM(FeePayment.amount) AS [Last Payment Amount],
                              PlanPaymentArrangement.startdate, street1, street2, DefendantPlans.noncompliancenotice AS Noncompliance
                         FROM Defendant
              LEFT OUTER JOIN DefendantPlans ON Defendant.defendantid = DefendantPlans.defendantid
              LEFT OUTER JOIN (
	                          SELECT defendantid, planid, MAX(receiveddate) AS receiveddate
                                FROM FeePayment
	                        GROUP BY defendantid, planid
                              ) AS LastPayment ON DefendantPlans.defendantid = LastPayment.defendantid AND DefendantPlans.planid = LastPayment.planid  
              LEFT OUTER JOIN FeePayment ON LastPayment.defendantid = FeePayment.defendantid AND FeePayment.planid = LastPayment.planid AND FeePayment.receiveddate = LastPayment.receiveddate
                   INNER JOIN PlanPaymentArrangement ON DefendantPlans.defendantid = PlanPaymentArrangement.defendantid AND DefendantPlans.planid = PlanPaymentArrangement.planid
                        WHERE Defendant.active = 1 AND DefendantPlans.planid IS NOT NULL AND NOT( Defendant.street1 = '' AND Defendant.street2 = '')
				              AND NOT EXISTS (
					                         SELECT defendantid, planid
						                       FROM (
					                                SELECT defendantid, planid, SUM(amount) AS total
													  FROM PlanFee 
											      GROUP BY defendantid, planid
												     UNION
												    SELECT defendantid, planid, -SUM( amount  ) AS total
												      FROM FeePayment
												  GROUP BY defendantid, planid
											        ) AS Transactions
										   	  WHERE Transactions.defendantid = DefendantPlans.defendantid AND Transactions.planid = DefendantPlans.planid 
										   GROUP BY defendantid, planid
										     HAVING SUM(total) = 0
										     ) 
                     GROUP BY Defendant.defendantid, lastname, firstname, middlename, DefendantPlans.planid, planname, isfiled, LastPayment.receiveddate, PlanPaymentArrangement.startdate, PlanPaymentArrangement.amount, street1, street2, DefendantPlans.noncompliancenotice
				       ) AS a 
              GROUP BY a.defendantid, a.lastname, a.firstname, a.middlename, a.planid, a.planname, a.isfiled, a.[Last Payment Date], a.[Last Payment Amount], a.street1, a.street2, Noncompliance
		        ) AS b 
     INNER JOIN PlanPaymentArrangement ON b.defendantid = PlanPaymentArrangement.defendantid AND b.planid = PlanPaymentArrangement.planid AND b.[current payment arrangement start date] = PlanPaymentArrangement.startdate
     INNER JOIN PayPeriodTypes ON PlanPaymentArrangement.payperiodtypeid = PayPeriodTypes.payperiodtypeid )
         AS z --where [Last Payment Amount] is not null
ORDER BY lastname, firstname, planname

END






SET ANSI_NULLS ON

GO
/****** Object:  StoredProcedure [dbo].[Report_BalanceLess100]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Scott Owen
-- Create date: 10/7/2012
-- =============================================
CREATE PROCEDURE [dbo].[Report_BalanceLess100] 
AS
BEGIN

	SET NOCOUNT ON;


             SELECT d.defendantid, d.firstname + ' ' + d.middlename AS firstmiddle, d.lastname, SUM(pf.amount) - ISNULL( paid, 0 ) AS balance
			   FROM Defendant d
	LEFT OUTER JOIN PlanFee pf ON d.defendantid = pf.defendantid
	LEFT OUTER JOIN ( 
							 SELECT d.defendantid, SUM( pf.amount ) AS paid
							   FROM Defendant d
					LEFT OUTER JOIN FeePayment pf ON d.defendantid = pf.defendantid
						   GROUP BY d.defendantid
					) 
					AS e ON e.defendantid = d.defendantid
              WHERE active = 1
		   GROUP BY d.defendantid, d.firstname + ' ' + d.middlename, d.lastname, paid
			 HAVING SUM(pf.amount) - ISNULL( paid, 0 ) < 100
		   ORDER BY lastname, firstmiddle  


END

GO
/****** Object:  StoredProcedure [dbo].[Report_CollectionsBreakdown]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Scott Owen
-- Create date: 10/7/2012
-- =============================================
CREATE PROCEDURE [dbo].[Report_CollectionsBreakdown] 

	@fromdate DateTime,
	@todate DateTime

AS
BEGIN

	SET NOCOUNT ON;


		 SELECT d.lastname, d.firstname + ' ' + d.middlename AS firstname, plans.planname, feetype.feetype, payment.receiveddate, payment.amount 
           FROM Defendant d
	 INNER JOIN DefendantPlans AS plans ON d.defendantid = plans.defendantid 
	 INNER JOIN PlanFee as fee ON plans.planid = fee.planid AND plans.defendantid = fee.defendantid 
     INNER JOIN FeePayment as payment ON fee.planid = payment.planid AND fee.defendantid = payment.defendantid AND fee.feetypeid = payment.feetypeid 
     INNER JOIN FeeTypes as feetype ON fee.feetypeid = feetype.feetypeid 
          WHERE payment.receiveddate > @fromdate AND payment.receiveddate < @todate 
       ORDER BY d.lastname, d.firstname, plans.planname, feetype.paymentorder, payment.receiveddate
                

END

GO
/****** Object:  StoredProcedure [dbo].[Report_CommitDateStatus]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Scott Owen
-- Create date: 10/7/2012
-- =============================================
CREATE PROCEDURE [dbo].[Report_CommitDateStatus] 
AS
BEGIN

	SET NOCOUNT ON;


				SELECT firstname + ' ' + middlename AS firstname, lastname, DefendantPlans.planname, PlanCase.casename, PlanCase.commitdate, 
                       CASE WHEN PlanCase.commitdate >= GETDATE() THEN 'Current' ELSE 'Overdue' END AS [status] 
				  FROM defendant 
		    INNER JOIN DefendantPlans ON Defendant.defendantid = DefendantPlans.defendantid 
            INNER JOIN PlanCase ON DefendantPlans.defendantid = PlanCase.defendantid AND DefendantPlans.planid = PlanCase.planid 
                 WHERE [committed] = 0 AND commitdate IS NOT NULL AND active = 1
              ORDER BY commitdate ASC, lastname, firstname


END

GO
/****** Object:  StoredProcedure [dbo].[Report_JailRoomBoard]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*******************************************************************************************************************
Author:  Seth Swanson
Date:    04/15/2010
Name:    Report_JailRoomBoard
Version: 1.0.0.0

Calling Arguments:

	Name            I/O Description
	--------------- --- ----------------------------------------------------------------------------------------------
	@input_DateTime	 I  The date to determine account deliquency from.

Updated:     Scott Owen (10/07/2012) renamed from sp_prison_room_and_board to Print_DelinquentNotices.
*******************************************************************************************************************/

CREATE PROCEDURE [dbo].[Report_JailRoomBoard] 
(
	@input_DateTime DateTime
)
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
	SET NOCOUNT ON;


  select lastname, firstname, planname, Payment, LastPaymentDate, PeriodType, TotalOwed - TotalPaid AS AmountLeft, TotalOwed,
	CASE 
		WHEN UPPER(PeriodType) = 'MONTHLY' THEN PaymentAmount * DATEDIFF( MONTH, PaymentStartDate, @input_DateTime )
		WHEN UPPER(PeriodType) = 'WEEKLY' THEN  PaymentAmount * DATEDIFF( MONTH, PaymentStartDate, @input_DateTime )
		WHEN UPPER(PeriodType) = 'BI-MONTHLY' THEN PaymentAmount * DATEDIFF( MONTH, PaymentStartDate, @input_DateTime )
		WHEN UPPER(PeriodType) = 'BI-WEEKLY' THEN PaymentAmount * DATEDIFF( MONTH, PaymentStartDate, @input_DateTime )
		ELSE 0
	END AS ShouldHavePaid, TotalPaid,
	CASE 
		WHEN UPPER(PeriodType) = 'MONTHLY' THEN DATEDIFF( DAY ,DATEADD( MONTH, (DATEDIFF( MONTH, PaymentStartDate, @input_DateTime ) - ((PaymentAmount * DATEDIFF( MONTH, PaymentStartDate, @input_DateTime )) - TotalPaid )/PaymentAmount), PaymentStartDate ), @input_DateTime)
		WHEN UPPER(PeriodType) = 'WEEKLY' THEN DATEDIFF( DAY ,DATEADD( WEEK, (DATEDIFF( WEEK, PaymentStartDate, @input_DateTime ) - ((PaymentAmount * DATEDIFF( WEEK, PaymentStartDate, @input_DateTime )) - TotalPaid )/PaymentAmount ), PaymentStartDate ), @input_DateTime)
		WHEN UPPER(PeriodType) = 'BI-MONTHLY' THEN DATEDIFF( DAY ,DATEADD( MONTH, ((DATEDIFF( MONTH, PaymentStartDate, @input_DateTime ) * 2) - ((PaymentAmount * DATEDIFF( MONTH, PaymentStartDate, @input_DateTime ) * 2) - TotalPaid )/PaymentAmount ) * 2, PaymentStartDate ), @input_DateTime)
		WHEN UPPER(PeriodType) = 'BI-WEEKLY' THEN DATEDIFF( DAY ,DATEADD( WEEK, ((DATEDIFF( MONTH, PaymentStartDate, @input_DateTime ) * 2) - ((PaymentAmount * DATEDIFF( MONTH, PaymentStartDate, @input_DateTime ) * 2) - TotalPaid )/PaymentAmount ) * 2, PaymentStartDate ), @input_DateTime)
        ELSE 0
	END AS DaysBehind
from 
	(select distinct b.lastname, b.firstname + ' ' + b.middlename as firstname, a.planname,
	(select top 1 amount from FeePayment where planid = a.planid and feetypeid = 22 order by receiveddate) as Payment,
	(select ISNULL(sum(amount), 0) from FeePayment where planid = a.planid and feetypeid = 22) as TotalPaid,
	(select amount from PlanFee where planid = a.planid and feetypeid = 22) as TotalOwed,
	(select top 1 receiveddate from FeePayment where planid = a.planid and feetypeid = 22 order by receiveddate) as LastPaymentDate,
	d.payperiodtype as PeriodType, c.startdate as PaymentStartDate, c.amount as PaymentAmount
	from DefendantPlans as a
		inner join Defendant as b on a.defendantid = b.defendantid
		left outer join PlanPaymentArrangement as c on a.planid = c.planid
		left outer join PayPeriodTypes as d on c.payperiodtypeid = d.payperiodtypeid
	where a.planid in (select planid from PlanFee where feetypeid = 22)) as results
--where TotalPaid != TotalOwed or TotalPaid is null
order by lastname, firstname


END

GO
/****** Object:  StoredProcedure [dbo].[Report_NonCompliance]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Scott Owen
-- Create date: 10/9/2012
-- =============================================
CREATE PROCEDURE [dbo].[Report_NonCompliance] 
AS
BEGIN

	SET NOCOUNT ON;


             SELECT d.defendantid, d.firstname + ' ' + d.middlename AS firstmiddle, d.lastname, dp.planname, dp.fileddate,
                    SUM(ISNULL(pf.amount,0)) as owed, ISNULL(paid,0) AS paid, SUM(ISNULL(pf.amount,0))- ISNULL( paid, 0 ) AS balance
			   FROM Defendant d
		 INNER JOIN DefendantPlans dp ON d.defendantid = dp.defendantid			   
    LEFT OUTER JOIN PlanFee pf ON d.defendantid = pf.defendantid AND dp.planid = pf.planid
	LEFT OUTER JOIN ( 
							 SELECT d.defendantid, dp.planid, SUM( pf.amount ) AS paid
							   FROM Defendant d
					     INNER JOIN DefendantPlans dp ON d.defendantid = dp.defendantid							   
					LEFT OUTER JOIN FeePayment pf ON d.defendantid = pf.defendantid AND dp.planid = pf.planid
					          WHERE active = 1 AND dp.noncompliancenotice = 1
						   GROUP BY d.defendantid, dp.planid
					) 
					AS e ON e.defendantid = d.defendantid AND e.planid = dp.planid
             WHERE active = 1 AND dp.noncompliancenotice = 1
		  GROUP BY d.defendantid, d.firstname + ' ' + d.middlename, d.lastname, dp.planname, dp.fileddate, paid
		  ORDER BY lastname, firstmiddle  


END

GO
/****** Object:  StoredProcedure [dbo].[Report_Restitution]    Script Date: 4/12/2017 4:54:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Scott Owen
-- Create date: 10/7/2012
-- =============================================
CREATE PROCEDURE [dbo].[Report_Restitution] 
AS
BEGIN

	SET NOCOUNT ON;


             SELECT d.defendantid, d.firstname + ' ' + d.middlename AS firstmiddle, d.lastname, 
                    SUM(pf.amount) as owed, ISNULL(paid,0) AS paid, SUM(pf.amount)- ISNULL( paid, 0 ) AS balance, z.receiveddate AS lastreceiveddate, z.amount AS lastpayment
			   FROM Defendant d
	     INNER JOIN PlanFee pf ON d.defendantid = pf.defendantid
	LEFT OUTER JOIN ( 
							 SELECT d.defendantid, SUM( pf.amount ) AS paid
							   FROM Defendant d
					LEFT OUTER JOIN FeePayment pf ON d.defendantid = pf.defendantid
					          WHERE pf.feetypeid = 20
						   GROUP BY d.defendantid
					) 
					AS e ON e.defendantid = d.defendantid
   LEFT OUTER JOIN (select defendantid, MAX(receiveddate) as receiveddate from FeePayment where feetypeid = 20 group by defendantid) as b on d.defendantid = b.defendantid
   LEFT OUTER JOIN (select defendantid, amount, receiveddate from FeePayment where feetypeid = 20) as z on d.defendantid = z.defendantid AND b.receiveddate = z.receiveddate
             WHERE active = 1 AND pf.feetypeid = 20
		  GROUP BY d.defendantid, d.firstname + ' ' + d.middlename, d.lastname, paid, z.receiveddate, z.amount
		    HAVING SUM(pf.amount)- ISNULL( paid, 0 ) > 0
		  ORDER BY lastname, firstmiddle  


END

GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "SYSPROCESSES (MASTER.DBO)"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 114
               Right = 190
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 1440
         Table = 2805
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_activeconnections'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_activeconnections'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Defendant"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 125
               Right = 221
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_ClerkReport'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vw_ClerkReport'
GO
USE [master]
GO
ALTER DATABASE [civilfeecollections] SET  READ_WRITE 
GO
