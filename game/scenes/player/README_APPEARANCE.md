# Sistema Modular de Aparência do Player

## 📋 Visão Geral

O player agora usa um sistema de **camadas modulares** que permite personalizar facilmente a aparência trocando texturas PNG. Cada parte do corpo é uma camada separada que pode ser ativada/desativada e personalizada.

## 🎨 Estrutura de Camadas

As camadas são renderizadas na seguinte ordem (de trás para frente):

1. **Layer 0**: Cabelo Traseiro (`layer0_back_hair/`)
2. **Layer 1**: Pele (`layer1_skin/`) - **OBRIGATÓRIA**
3. **Layer 2**: Olhos (`layer2_eyes/`)
4. **Layer 3**: Camisa (`layer3_shirt/`)
5. **Layer 6**: Calças (`layer6_pants/`)
6. **Layer 5**: Sapatos (`layer5_shoes/`)
7. **Layer 4**: Cabelo Frontal (`layer4_front_hair/`)
8. **Acessórios**: Óculos (`unisex_accessories/`)
9. **Acessórios**: Chapéu (`unisex_accessories/`)

## 🔧 Como Personalizar

### Método 1: Editando o Resource no Godot Editor

1. Abra `scenes/player/default_appearance.tres` no inspetor
2. Modifique os campos:
   - **Gender**: Female (0) ou Male (1)
   - **Skin Texture**: Nome do arquivo PNG (ex: `female_skin_02.png`)
   - **Eyes Enabled**: Marque/desmarque para mostrar/ocultar
   - **Eyes Texture**: Nome do arquivo PNG
   - E assim por diante para cada camada...

### Método 2: Criando um Novo Resource de Aparência

1. Crie um novo Resource do tipo `PlayerAppearance`:
   ```
   Botão direito → New Resource → PlayerAppearance
   ```

2. Configure as propriedades:
   ```gdscript
   gender = 0  # 0 = Female, 1 = Male
   skin_texture = "female_skin_01.png"
   eyes_texture = "female_eyes_02.png"
   eyes_enabled = true
   shirt_texture = "female_shirt_05.png"
   shirt_enabled = true
   # ... etc
   ```

3. Salve o resource (ex: `my_custom_appearance.tres`)

4. No player scene, altere o campo `Appearance` para apontar para seu novo resource

### Método 3: Via Código

```gdscript
# Cria uma nova aparência
var new_appearance = PlayerAppearance.new()
new_appearance.gender = 0  # Female
new_appearance.skin_texture = "female_skin_02.png"
new_appearance.eyes_texture = "female_eyes_03.png"
new_appearance.shirt_texture = "female_shirt_10.png"

# Aplica no player
$Player.appearance = new_appearance
$Player.apply_appearance()
```

## 📁 Estrutura de Arquivos

```
assets/sprites/characters/player/
├── female/
│   ├── layer0_back_hair/
│   │   ├── female_hair_05_b.png
│   │   ├── female_hair_06_b.png
│   │   └── ...
│   ├── layer1_skin/
│   │   ├── female_skin_01.png
│   │   ├── female_skin_02.png
│   │   └── ...
│   ├── layer2_eyes/
│   ├── layer3_shirt/
│   ├── layer4_front_hair/
│   ├── layer5_shoes/
│   └── layer6_pants/
├── male/
│   └── (mesma estrutura)
└── unisex_accessories/
    ├── unisex_glasses1.png
    ├── unisex_hat1.png
    └── ...
```

## 🎯 Exemplos de Uso

### Personagem Feminino Completo
```tres
gender = 0
skin_texture = "female_skin_01.png"
eyes_texture = "female_eyes_01.png"
eyes_enabled = true
shirt_texture = "female_shirt_05.png"
shirt_enabled = true
front_hair_texture = "female_hair_02.png"
front_hair_enabled = true
pants_texture = "female_pants_01.png"
pants_enabled = true
shoes_texture = "female_shoes_01.png"
shoes_enabled = true
glasses_texture = "unisex_glasses1.png"
```

### Personagem Masculino Simples
```tres
gender = 1
skin_texture = "male_skin_01.png"
eyes_texture = "male_eyes_01.png"
eyes_enabled = true
shirt_texture = "male_shirt_01.png"
shirt_enabled = true
# Demais camadas desabilitadas
```

## 🔄 Trocando Aparência em Tempo de Execução

```gdscript
# Trocar apenas a camisa
$Player.appearance.shirt_texture = "female_shirt_15.png"
$Player.apply_appearance()

# Adicionar óculos
$Player.appearance.glasses_texture = "unisex_glasses3.png"
$Player.apply_appearance()

# Remover chapéu
$Player.appearance.hat_texture = ""
$Player.apply_appearance()
```

## ⚙️ Requisitos Técnicos

### Formato dos Spritesheets
- **Dimensões por frame**: 64x98 pixels
- **Total de colunas**: 9 (1 idle + 8 walk frames)
- **Total de linhas**: 8 (uma para cada direção)
- **Tamanho total**: 576x784 pixels

### Ordem das Direções (linhas)
1. Down (↓)
2. Down-Right (↘)
3. Right (→)
4. Up-Right (↗)
5. Up (↑)
6. Up-Left (↖)
7. Left (←)
8. Down-Left (↙)

## 💡 Dicas

- **Skin é obrigatória**: Sempre defina uma textura de pele
- **Acessórios são opcionais**: Deixe vazio (`""`) para não usar
- **Ordem importa**: As camadas são renderizadas na ordem definida
- **Gênero muda a pasta**: Female usa `female/`, Male usa `male/`
- **Cache automático**: O sistema gera os SpriteFrames automaticamente

## 🐛 Troubleshooting

**Problema**: Camada não aparece
- Verifique se o campo `*_enabled` está marcado
- Confirme que o nome do arquivo está correto
- Verifique se o PNG existe na pasta correta

**Problema**: Animação não sincroniza
- Todas as camadas usam os mesmos nomes de animação
- Certifique-se que o spritesheet segue o formato padrão

**Problema**: Performance baixa
- Desabilite camadas não utilizadas
- Evite mudar a aparência todo frame
