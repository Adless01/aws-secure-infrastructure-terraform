environment   = "prod"
project_name  = "CombatSec"
instance_type = "t3.small"  # Na produkcji chcemy mocniejsze maszyny niż t3.micro!
asg_max_size  = 4           # W razie dużego ruchu, produkcja sklonuje się aż do 4 maszyn