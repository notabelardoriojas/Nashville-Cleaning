USE PortfolioProject;


#Standardize date format
select cast(saledate as date) as Date_of_Sale from nashville ;

UPDATE nashville
SET saledate = cast(saledate as date);

#Populate null PropertyAddress where parcelid matches a populated address


#select * from nashville where length(propertyaddress) = 0;

UPDATE nashville
	SET PropertyAddress = NULL
	WHERE PropertyAddress = '';

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.propertyaddress, b.propertyaddress)
FROM nashville a
JOIN nashville b
	ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;


UPDATE nashville a 
	JOIN nashville b
		ON a.ParcelID = B.ParcelID
        AND a.UniqueID <> b.UniqueID
set a.propertyaddress = IFNULL(a.propertyaddress, b.propertyaddress)
WHERE a.PropertyAddress is NULL;


#Breaking out addresses into individual columns (street, city, state)

SELECT propertyaddress, 
	substring(propertyaddress, 1, locate(',',propertyaddress)-1) as Street,
    substring(propertyaddress, locate(',',propertyaddress)+1) as City
FROM nashville;

ALTER TABLE nashville
ADD Street NVARCHAR(255);

UPDATE nashville
SET Street = substring(propertyaddress, 1, locate(',',propertyaddress)-1);

ALTER TABLE nashville
ADD City NVARCHAR(255);

UPDATE nashville
SET City = substring(propertyaddress, locate(',',propertyaddress)+1);

#select * from nashville;

#Doing the same thing but with owner address using SUBSTRING_INDEXX

SELECT
	owneraddress,
	SUBSTRING_INDEX(owneraddress, ',', -1) as owner_state,
	SUBSTRING_INDEX(owneraddress, ',', 1) as owner_address,
	SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1) as owner_city
FROM 
	nashville;

ALTER TABLE nashville
ADD owner_state NVARCHAR(255);

UPDATE nashville
SET owner_state = SUBSTRING_INDEX(owneraddress, ',', -1);

ALTER TABLE nashville
ADD owner_address NVARCHAR(255);

UPDATE nashville
SET owner_address = SUBSTRING_INDEX(owneraddress, ',', 1);

ALTER TABLE nashville
ADD owner_city NVARCHAR(255);

UPDATE nashville
SET owner_city = SUBSTRING_INDEX(SUBSTRING_INDEX(owneraddress, ',', 2), ',', -1);

#select * from nashville;

#Clean up 'Sold as vacant'

SELECT 
	distinct(SoldasVacant), 
	count(SoldAsVacant) 
FROM 
	nashville 
GROUP BY
	soldasvacant; 
    
#outputs are No, N, Yes, and Y

#Let's change N and Y to No and Yes are they are the more populated response
#Use case statement

SELECT 
	soldasvacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
from nashville;

#This worked! Let's update the table

UPDATE nashville
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END;

Select * from nashville;

#Remove duplicates 


DELETE t1 FROM nashville t1
INNER JOIN nashville t2 
WHERE 
    t1.UniqueID < t2.UniqueID AND 
    t1.PropertyAddress = t2.PropertyAddress AND
    t1.ParcelID = t2.ParcelID AND
    t1.LegalReference = t2.LegalReference AND
    t1.SaleDate = t2.SaleDate AND
    t1.SalePrice = t2.SalePrice;