select *
from [dbo].[NashvilleHouses]

-- Changing the formatting of the SaleDate column
select SaleDate, CONVERT(Date,SaleDate)
from [dbo].[NashvilleHouses]

-- Adding a new column to the table with the right formatting

ALTER TABLE NashvilleHouses
Add SaleDateUpdated Date;

Update NashvilleHouses
SET SaleDateUpdated = CONVERT(Date,SaleDate)

-- Deleting the previous date column
ALTER TABLE NashvilleHouses
DROP COLUMN SaleDate;


-- Resolving the issue with the null addresses.
select *
from [dbo].[NashvilleHouses]
where PropertyAddress is null

-- Each ParcelID represents the same address, we can use that to change the Null values to the correct address
select x.[UniqueID ], x.ParcelID, y.ParcelID, x.PropertyAddress, y.PropertyAddress, 
ISNULL(x.PropertyAddress, y.PropertyAddress) as Address
from [dbo].[NashvilleHouses] x
JOIN [dbo].[NashvilleHouses] y
	ON x.ParcelID = y.ParcelID
	AND x.[UniqueID ] <> y.[UniqueID ]
where x.PropertyAddress is null

Update x
SET PropertyAddress = ISNULL(x.PropertyAddress, y.PropertyAddress)
from [dbo].[NashvilleHouses] x
JOIN [dbo].[NashvilleHouses] y
	ON x.ParcelID = y.ParcelID
	AND x.[UniqueID ] <> y.[UniqueID ]
Where x.PropertyAddress is null

-- Separating the data inserted into the PropertyAdress column using the SUBSTRING function
select PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as StreetAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) as City
from [dbo].[NashvilleHouses]

ALTER TABLE [dbo].[NashvilleHouses]
Add StreetAddress nvarchar(255);

Update [dbo].[NashvilleHouses]
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [dbo].[NashvilleHouses]
Add City nvarchar(255);

Update [dbo].[NashvilleHouses]
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress))


-- Separating the data inserted into OwnerAddress column using the PARSENAME function
select OwnerAddress
from [dbo].[NashvilleHouses]

select OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerStreet,
TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)) as OwnerCity,
TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)) as OwnerState
from [dbo].[NashvilleHouses]

ALTER TABLE [dbo].[NashvilleHouses]
Add OwnerStreet nvarchar(255),
	OwnerCity nvarchar(255),
	OwnerState nvarchar(255);

Update [dbo].[NashvilleHouses]
SET OwnerStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	OwnerCity = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)),
	OwnerState = TRIM(PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1))

-- Padronizing the SoldAsVacant column
select Distinct SoldAsVacant
from [dbo].[NashvilleHouses]


select SoldAsVacant,
UPPER(CASE when SoldAsVacant = 'N' then 'NO'
	 when SoldAsVacant = 'Y' then 'YES'
	 ELSE SoldAsVacant
	 END)
from [dbo].[NashvilleHouses]

Update [dbo].[NashvilleHouses]
SET SoldAsVacant = UPPER(CASE when SoldAsVacant = 'N' then 'NO'
	 when SoldAsVacant = 'Y' then 'YES'
	 ELSE SoldAsVacant
	 END)