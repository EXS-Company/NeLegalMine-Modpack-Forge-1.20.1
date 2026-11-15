# История изменений

## 2026-11-15 — Visual and compatibility cleanup

### Исправлено

- отключён FirstPerson, вызывавший дополнительный рендер тела;
- отключён Fresh Animations Player Extension, конфликтовавший с EMF и моделью игрока;
- Camera Overhaul отключён для режима F5;
- выключен дождевой водяной оверлей Psychedelicraft;
- четыре creative-вкладки Psychedelicraft объединены в одну;
- сохранены все исходные ресурсы и русский перевод Psychedelicraft;
- добавлен пакет моделей предметов Psychedelicraft для 1.20.1;
- отключены несовместимые Actually 3D и его старый compatibility-пак;
- сохранён 3D Items Vanillaism как основной пакет объёмных предметов.

### Оптимизация

- CPU Render Ahead: 7 → 3;
- удалены из активной папки старые дубли библиотек и MineColonies;
- APKTool перемещён из `mods` в резервную копию;
- очищен только кэш Connector для изменённого Psychedelicraft.

### Шейдер

- основа Medium/High;
- отключены TAA, Motion Blur, DOF, Lens Glare и Lens Flare;
- Bloom снижен до 0.07;
- уменьшены насыщенность и дождевые искажения;
- сохранены GI, PBR, объёмные облака и туман среднего качества.
