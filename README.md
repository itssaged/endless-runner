# 🐱 Floppa Endless Runner

A 3D endless runner game built with **Godot Engine**, where you play as Floppa running through a university corridor while avoiding obstacles, collecting coins, and trying to beat your high score.

But there's a problem...

**A chicken is chasing you. 🐔**

---

## 🎮 About the Game

**Floppa Endless Runner** is a fast-paced 3D endless runner inspired by classic lane-based runner games.

The game takes place inside a university corridor. Floppa automatically runs forward while the player must react to obstacles, switch lanes, jump, and collect coins.

As the run continues, the game becomes progressively faster and more challenging.

A chasing chicken adds an additional layer of pressure to the gameplay.

---

## ✨ Features

* 🏃 **Endless runner gameplay**
* ↔️ **Three-lane movement system**
* ⬆️ **Jump and fast-fall mechanics**
* 🪙 **Coin collection**
* 📊 **Score system**
* 🏆 **High-score tracking**
* 🚧 **Dynamic obstacle spawning**
* 📈 **Progressive difficulty**
* 🐔 **Chasing chicken enemy**
* 🎬 **Character animations**
* 🎵 **Background music and sound effects**
* 🏫 **University-themed 3D environment**
* 🎮 **Main menu and game-over system**

---

## 🕹️ Controls

| Action     | Control   |
| ---------- | --------- |
| Move Left  | `A` / `←` |
| Move Right | `D` / `→` |
| Jump       | `Space`   |
| Fast Fall  | `S` / `↓` |

---

## 🎯 Gameplay

The objective is simple:

> **Run as far as possible without hitting obstacles.**

While running:

1. Switch between the three lanes.
2. Jump over obstacles.
3. Collect coins.
4. Avoid getting caught.
5. Survive as long as possible.
6. Beat your previous high score.

The game speed gradually increases, making longer runs increasingly difficult.

---

## 🐔 The Chicken

Floppa isn't alone.

A chicken follows behind the player throughout the run, creating constant pressure and making mistakes more costly.

The chicken also has its own animations, including running and attack animations.

---

## 🛠️ Built With

* **Godot Engine 4.7.2**
* **GDScript**
* **Blender**
* **3D Assets / FBX / GLB**

---

## 📂 Project Structure

```text
Floppa-Runner/
│
├── scenes/
│   ├── world.tscn
│   ├── player.tscn
│   ├── desk.tscn
│   ├── coin.tscn
│   └── modules/
│
├── scripts/
│   ├── player.gd
│   ├── global.gd
│   └── ...
│
├── assets/
│   ├── models/
│   ├── textures/
│   ├── animations/
│   └── audio/
│
└── project.godot
```

*Project structure may change as development continues.*

---

## 📈 Difficulty System

The game uses a progressive difficulty system.

The player's movement speed starts at a lower value and gradually increases as the run continues.

This means:

**Longer run → Higher speed → Faster reactions required → Higher difficulty**

Obstacle spawning is also dynamically handled to keep the gameplay challenging while maintaining playable gaps between obstacles.


## 🎨 Development

This project was created as a personal game development project to practice:

* 3D game development
* Character controllers
* Game physics
* Animation systems
* Procedural/dynamic spawning
* UI systems
* Game progression and difficulty
* Audio integration
* Backend/leaderboard integration

---

## 🚀 Future Plans

* [ ] Complete Supabase online leaderboard
* [ ] Add more obstacles
* [ ] Add more university environments
* [ ] Add power-ups
* [ ] Add additional characters
* [ ] Add more animations
* [ ] Improve visual effects
* [ ] Add mobile support
* [ ] Release a playable build

---

## 📸 Screenshots

Screenshots and gameplay footage will be added here as development progresses.

---

## 👨‍💻 Developer

Developed as a personal game development project using **Godot Engine**.

---

## 📜 License

This project is currently for educational and personal development purposes.

Third-party assets used in the project may have their own licenses and terms of use.
