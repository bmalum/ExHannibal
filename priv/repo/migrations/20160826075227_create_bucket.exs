defmodule ExHannibal.Repo.Migrations.CreateBucket do
  use Ecto.Migration

  def change do
    create table(:buckets) do
      add :api_key, :string

      timestamps
    end

  end
end
