// THIS IS A SIMULATION
// main.rs
use bevy::prelude::*;
use std::time::Duration;

// Components
#[derive(Component)]
struct CatUnit;

#[derive(Component)]
struct EnemyBase {
    health: i32,
}

#[derive(Resource)]
struct PlayerMoney(i32);

// Spawn event
#[derive(Event)]
struct SpawnUnit;

fn main() {
    App::new()
        .insert_resource(PlayerMoney(0))
        .add_startup_system(setup)
        .add_event::<SpawnUnit>()
        .add_system(gain_money)
        .add_system(unit_spawner)
        .add_system(move_units)
        .add_system(damage_enemy_base)
        .run();
}

fn setup(mut commands: Commands) {
    // Add enemy base
    commands.spawn()
        .insert(EnemyBase { health: 100 })
        .insert(Transform::from_xyz(50.0, 0.0, 0.0))
        .insert(GlobalTransform::default());

    println!("Battle Cats remake in Rust + Bevy");
}

fn gain_money(mut money: ResMut<PlayerMoney>, time: Res<Time>, mut timer: Local<Timer>) {
    if timer.tick(time.delta()).just_finished() {
        money.0 += 1;
        println!("Money: ₩{}", money.0);
    }
}

fn unit_spawner(
    mut commands: Commands,
    mut spawn_events: EventReader<SpawnUnit>,
    mut money: ResMut<PlayerMoney>,
) {
    for _event in spawn_events.iter() {
        if money.0 >= 25 {
            money.0 -= 25;
            commands.spawn()
                .insert(CatUnit)
                .insert(Transform::from_xyz(-50.0, 0.0, 0.0))
                .insert(GlobalTransform::default());
            println!("Spawned cat unit.");
        } else {
            println!("Not enough ₩머니.");
        }
    }
}

fn move_units(
    mut query: Query<&mut Transform, With<CatUnit>>,
) {
    for mut transform in query.iter_mut() {
        transform.translation.x += 0.5;
    }
}

fn damage_enemy_base(
    mut commands: Commands,
    mut units: Query<(Entity, &Transform), With<CatUnit>>,
    mut base_query: Query<(&mut EnemyBase, &Transform)>,
) {
    for (mut base, base_transform) in base_query.iter_mut() {
        for (entity, transform) in units.iter_mut() {
            let distance = base_transform.translation.distance(transform.translation);
            if distance < 5.0 {
                base.health -= 10;
                println!("Enemy base hit! HP: {}", base.health);
                commands.entity(entity).despawn();

                if base.health <= 0 {
                    println!("Enemy base destroyed!");
                    commands.entity(base_query.single_mut().0).despawn();
                }
            }
        }
    }
}
