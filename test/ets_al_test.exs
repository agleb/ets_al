defmodule EtsAlTest do
  use ExUnit.Case
  import EtsAl.Keeper
  doctest EtsAl

  test "create_table -> delete_table" do
    delete_table(:table_id)
    assert {:ok, _} = create_table(:table_id, [:set, :named_table])
    assert {:ok, _} = delete_table(:table_id)
  end

  test "create_table incorrect params" do
    delete_table(:table_id)
    assert {:error, _} = create_table("table_id", [:set, :named_table])
  end

  test "create_public_bag -> delete_table" do
    delete_table(:table_id)
    assert {:ok, _} = create_public_bag(:table_id)
    assert {:ok, _} = delete_table(:table_id)
  end

  test "create_public_ordered_set -> delete_table" do
    delete_table(:table_id)
    assert {:ok, _} = create_public_ordered_set(:table_id)
    assert {:ok, _} = delete_table(:table_id)
  end

  test "create_public_set -> delete_table" do
    delete_table(:table_id)
    assert {:ok, _} = create_public_set(:table_id)
    assert {:ok, _} = delete_table(:table_id)
  end

  test "create_public_set -> insert -> fetch -> delete_table" do
    delete_table(:table_id)
    assert {:ok, _} = create_public_set(:table_id)
    assert {:ok, _} = insert(:table_id, :key, [1, 2])
    assert {:ok, {:key, 1, 2}} = fetch(:table_id, :key)
    assert {:ok, _} = delete_table(:table_id)
  end

  test "create_public_set -> insert -> clear_table -> delete_table" do
    delete_table(:table_id)
    assert {:ok, _} = create_public_set(:table_id)
    assert {:ok, _} = insert(:table_id, :key, [1, 2])
    assert {:ok, _} = clear_table(:table_id)
    assert {:ok, nil} = fetch(:table_id, :key)
    assert {:ok, _} = delete_table(:table_id)
  end

  test "create_public_set -> insert batch -> fetch_range -> delete_table" do
    delete_table(:table_id)
    assert {:ok, _} = create_public_ordered_set(:table_id)

    for key <- 1..100 do
      insert(:table_id, key, [key * 10, key * 100])
    end

    assert fetch_range(:table_id, 54, 10) ==
             {:ok,
              [
                {54, 540, 5400},
                {55, 550, 5500},
                {56, 560, 5600},
                {57, 570, 5700},
                {58, 580, 5800},
                {59, 590, 5900},
                {60, 600, 6000},
                {61, 610, 6100},
                {62, 620, 6200},
                {63, 630, 6300}
              ]}
    assert {:ok, _} = clear_table(:table_id)
    assert {:ok, nil} = fetch(:table_id, 54)
    assert {:ok, _} = delete_table(:table_id)
  end
end
