$service1 = "test1"
$service2 = "Test2"
$service3 = "test3"
$name = $service1, $service2, $service3

foreach ($line in $name)
{
Restart-Service -Name $line -Force
}