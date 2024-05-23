
SELECT * 
FROM NashvilleHousing;

-----------------------------------------------------------------------------------

-- Standardize Date Format

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

-------------------------------------------------------------------------------

-- Populate Property Address Data

SELECT * 
FROM NashvilleHousing
ORDER BY ParcelID;

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress ,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;

-----------------------------------------------------------------------

--Breaking out Property Address into Individual Columns (Address,City)


SELECT 
SUBSTRING( PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING( PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING( PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING( PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress));

---------------------------------------------------------------------------------

--Breaking out Owner Address into Individual Columns (Address,City,State)

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-----------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant) 
FROM NashvilleHousing;


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
					END

-----------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID) row_num
FROM NashvilleHousing
)

DELETE 
FROM RowNumCTE
WHERE row_num > 1;

----------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE NashVilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress;

ALTER TABLE NashVilleHousing
DROP COLUMN SaleDate;



