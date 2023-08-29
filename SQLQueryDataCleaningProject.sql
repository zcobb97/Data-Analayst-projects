/* SQL Data Cleaning Project*/

Select * from PortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDate, CONVERT(date, SaleDate) from PortfolioProject.dbo.NashvilleHousing


Update PortfolioProject.dbo.NashvilleHousing
Set SaleDate = CONVERT(date, SaleDate)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add SaleDateConverted date;

Update PortfolioProject.dbo.NashvilleHousing
Set SaleDateConverted = CONVERT(date, SaleDate)

Select SaleDateConverted, CONVERT(date, SaleDate) from PortfolioProject.dbo.NashvilleHousing


--- Property Address Data

Select * from PortfolioProject.dbo.NashvilleHousing
Where PropertyAddress is Null

Select * from PortfolioProject.dbo.NashvilleHousing
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

-- Breaking out Address Into individual Columns (Address, City, State)

Select PropertyAddress from PortfolioProject.dbo.NashvilleHousing

-- delimiter seperates different columns. In this case its a ,

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


Alter Table PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select * from PortfolioProject.dbo.NashvilleHousing

--- Owner Address -> Parse Name

Select OwnerAddress from PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select * from PortfolioProject.dbo.NashvilleHousing

--- Change Y and N to yes and no in "Sold as vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
from PortfolioProject.dbo.NashvilleHousing

Update PortfolioProject.dbo.NashvilleHousing
Set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End


-- Remove Duplicates- not standard practice to delete data from db

With RowNumCTE AS(
Select *,
ROW_NUMBER() Over(
	Partition By ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		Order by UniqueID
) row_num
From PortfolioProject.dbo.NashvilleHousing
--Order by ParcelID
)

Select * from RowNumCTE
Where row_num > 1
Order by PropertyAddress


--Delete Unused Columns

Select * from PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column Saledate