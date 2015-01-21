#############################################################################################
#Version: V0.1
#Date : 21/01/2015
#Description: Windows Powershell script that changes the Computer Name of a new EC2 instance
#			  by reading a list of already used names in the domain from aws s3 and adds 
#			  the system to domain.
#############################################################################################

#Define the Source or the s3 urlof the List of used hostnames i.e. domainnames.txt and the destination of the file to be temporarily stored.
$source = "https://s3-<region>.amazonaws.com/<bucketname>/domainnames.txt"
$destination = "C:\Users\Administrator\Desktop\domainnames.txt"

Copy-S3Object -BucketName integrationtrck2cloud -Key domainnames.txt -LocalFile $destination
$Computerame=gc env:computername
$secpasswd = ConvertTo-SecureString "abc@123" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential("pandaoncloud",$secpasswd) #("<domain user name>",$secpasswd)

$i = 1
#check whether the system is in domain or not
if ((gwmi win32_computersystem).partofdomain -eq $true) {
    
}
Else{
    While($i -gt 0)
    {
        If ($i -lt 10 )
        {
        $PATTERN = "HZNWINDOTNET0$i"
        }
        Else{
        $PATTERN = "HZNWINDOTNET$i"
        }

        If (select-string -path $destination -Pattern $PATTERN ){
        $i++
         }
         Else{

           Add-Content $destination `n
           Add-Content $destination `n$PATTERN
           Write-S3Object -BucketName integrationtrck2cloud -Key domainnames.txt -File $destination
           $i=0
         
           Add-Computer -DomainName neo-diageo.com -NewName $PATTERN -Credential $mycreds -Restart
           
        }
    }
}
