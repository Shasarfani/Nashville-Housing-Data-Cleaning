--Cleaning in SQL

USE PortfolioProjects

select*
from PortfolioProjects.dbo.NashvilleHousing

--Change sales date

select SaleDate, CONVERT(Date,SaleDate)
from PortfolioProjects.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

select Sale_Date_Converted
from PortfolioProjects.dbo.NashvilleHousing

--it didn't work, lets try something else

ALTER TABLE NashvilleHousing
Add Sale_Date_Converted Date;

update NashvilleHousing
SET Sale_Date_Converted = CONVERT(Date, SaleDate) --now view the col, it should be converted


--populate property address data
select *
from PortfolioProjects.dbo.NashvilleHousing
--where propertyAddress is null
order by parcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	on a.parcelID = b.parcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) --ISNULL function checks if teh first col is null then populated it with the secind col mentioned
from PortfolioProjects.dbo.NashvilleHousing a
JOIN PortfolioProjects.dbo.NashvilleHousing b
	on a.parcelID = b.parcelID
	AND a.[UniqueID] <> b.[UniqueID] 

select *
from PortfolioProjects.dbo.NashvilleHousing a
where a.PropertyAddress is null -- n0 more null propert addresses

--breaking the address into individual cols for address,city & state

select PropertyAddress
from PortfolioProjects.dbo.NashvilleHousing
--where propertyAddress is null
--order by parcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address --substring lets yiu look at teh value & the charindex you can decide what to look for & -1 delted the last o,
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from PortfolioProjects.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertyStreetAddress Nvarchar(255);

Update NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertyCity Nvarchar(255);

Update NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

Select*
from PortfolioProjects.dbo.NashvilleHousing

--splitting owner address using parse name, it splits backwards

Select OwnerAddress
from PortfolioProjects.dbo.NashvilleHousing

select
parsename(REPLACE(OwnerAddress, ',', '.') , 3)
,parsename(REPLACE(OwnerAddress, ',', '.') , 2)
,parsename(REPLACE(OwnerAddress, ',', '.') , 1)
from PortfolioProjects.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerStreetAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerStreetAddress = parsename(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
Add OwnerCity Nvarchar(255);

Update NashvilleHousing
SET OwnerCity = parsename(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE NashvilleHousing
Add OwnerState Nvarchar(255);

Update NashvilleHousing
SET OwnerState = parsename(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
from PortfolioProjects.dbo.NashvilleHousing

--Change Y & N to Yes and No in Sold as Vacant

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProjects.dbo.NashvilleHousing
group by SoldAsVacant
Order by 2

select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   Else SOldAsVacant
	   END
from PortfolioProjects.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   Else SOldAsVacant
	   END

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProjects.dbo.NashvilleHousing
group by SoldAsVacant
Order by 2 --reviewing if the query updated the cols

--Remove Duplicates

WITH RowNumCTE as(
Select*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER  BY
					UniqueID
					) row_num
from PortfolioProjects.dbo.NashvilleHousing
--order by ParcelID
)
DELETE
from RowNumCTE
where row_num > 1
--order by PropertyAddress

-- delete unused cols

select *
from PortfolioProjects.dbo.NashvilleHousing

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProjects.dbo.NashvilleHousing
DROP COLUMN SaleDate