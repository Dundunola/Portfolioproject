--Cleaning data in SQL Queries

select *
from Portfolioproject..NashvilleHousing

--standardize date format

select SaleDateconverted, Convert(Date, Saledate)
from Portfolioproject..NashvilleHousing

update NashvilleHousing
SET saleDate = Convert(Date, SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted Date

Update NashvilleHousing
SET SaleDateconverted = Convert(Date, SaleDate)

--Populate property Address data
select *
from Portfolioproject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select NH.ParcelID, NH.PropertyAddress, NHS.ParcelID, NHS.PropertyAddress, ISNULL(NH.PropertyAddress, NHS.PropertyAddress) 
as Newpropertyaddress
from Portfolioproject..NashvilleHousing NH
JOIN Portfolioproject..NashvilleHousing NHS
	on NH.ParcelID = NHS.ParcelID 
	And NH.[UniqueID] <> NHS.[UniqueID ]
where NH.PropertyAddress is null

Update NH
Set propertyAddress = ISNULL(NH.PropertyAddress, NHS.PropertyAddress)
from Portfolioproject..NashvilleHousing NH
JOIN Portfolioproject..NashvilleHousing NHS
	on NH.ParcelID = NHS.ParcelID 
	And NH.[UniqueID] <> NHS.[UniqueID ]
where NH.PropertyAddress is null

--breaking out address into individual columns

select PropertyAddress
from Portfolioproject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

--N.B CHARINDEX is used to find something in the tables
--(negative 1 was used to remove the comma backwards then use + 1 to display the rest of the address without the comma)
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from Portfolioproject..NashvilleHousing


Alter table NashvilleHousing
Add PropertysplitAddress Nvarchar(255);

Update NashvilleHousing
SET  PropertysplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select * 
from Portfolioproject..NashvilleHousing 

Select OwnerAddress 
from Portfolioproject..NashvilleHousing

select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from Portfolioproject..NashvilleHousing
where OwnerAddress is not null

Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


Select *
from Portfolioproject..NashvilleHousing

--cahnge Y and N to yes and no in sold as vacant

Select Distinct(SoldAsVacant), count(soldasVacant)
from Portfolioproject..NashvilleHousing
Group by Soldasvacant
order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' Then 'Yes'
     when SoldAsVacant = 'N' Then 'NO'
	 Else SoldAsVacant
	 End
from Portfolioproject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
     when SoldAsVacant = 'N' Then 'NO'
	 Else SoldAsVacant
	 End


--Remove Duplicates
with RowNumCTE AS 
(select *, 
	ROW_NUMBER() OVER (
	Partition By ParcelID, 
				PropertyAddress,
				SalePrice,
				SaleDate,
				legalReference
	Order By UniqueID
	) row_num
from Portfolioproject..NashvilleHousing
--Order by ParcelID
)
Delete
from RowNumCTE
where row_num > 1
--order by PropertyAddress

--Delete unused columns

Alter Table Portfolioproject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table Portfolioproject..NashvilleHousing
Drop Column SaleDate

select * from Portfolioproject..NashvilleHousing